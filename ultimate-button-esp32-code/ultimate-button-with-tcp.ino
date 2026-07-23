#include <LilyGo_AMOLED.h>
#include <LV_Helper.h>
#include <WiFiManager.h>
#include <lvgl.h>
#include <ESPAsyncWebServer.h>
#include <AsyncTCP.h>
#include <AsyncWebSocket.h>

// ====================== CONFIGURABLE ======================
String buttonText = "Ultimate Button";
uint32_t bgColor = 0xFFFFFF;
uint32_t textColor = 0x000000;
uint8_t brightness = 200;

// Tap storage
struct TapEvent {
    uint8_t count = 0;
    unsigned long timestamp = 0;
};
TapEvent latestTap;

// ====================== OBJECTS ======================
LilyGo_Class amoled;
WiFiManager wifiManager;
AsyncWebServer server(80);
AsyncWebSocket ws("/ws");

// ---- Control4 Director TCP connection (matches driver.xml <port><number>1000</number>) ----
const uint16_t DIRECTOR_PORT = 1000;
AsyncServer directorServer(DIRECTOR_PORT);
AsyncClient *directorClient = nullptr;   // only one Director connection at a time
String directorRxBuffer;                 // accumulates partial lines

lv_obj_t * label;
lv_obj_t * statusLabel;

volatile uint8_t tapCount = 0;
unsigned long lastTapTime = 0;
const unsigned long TAP_TIMEOUT = 350;

const int CONFIG_BUTTON_PIN = 0;   // BOOT button - hold 5s for config

// ====================== FORWARD DECLARATIONS ======================
void startDirectorServer();
void sendToDirector(const String &line);
void handleDirectorLine(const String &line);
void emitInputEvent(const char *eventName);

volatile bool isTouchPressed = false;

// ====================== SETUP ======================
void setup() {
    Serial.begin(115200);
    delay(2000);
    Serial.println("\n=== Ultimate Button - Starting ===");

    pinMode(38, OUTPUT); digitalWrite(38, HIGH);
    pinMode(CONFIG_BUTTON_PIN, INPUT_PULLUP);

    bool rslt = amoled.begin();
    if (!rslt) { Serial.println("AMOLED FAILED!"); while(1) delay(1000); }
    delay(500);
    beginLvglHelper(amoled);

    amoled.setBrightness(brightness);

    createFullScreenUI();
    wifiManagerSetup();
    startWebServer();
    startDirectorServer();

    Serial.println("Setup complete!");
    updateStatusLabel();
}

void loop() {
    lv_timer_handler();
    delay(5);

    // Multi-tap processing
    if (tapCount > 0 && (millis() - lastTapTime > TAP_TIMEOUT)) {
        handleTap(tapCount);
        tapCount = 0;
    }

    // Config button (hold 10 seconds)
    static unsigned long buttonPressTime = 0;
    if (digitalRead(CONFIG_BUTTON_PIN) == LOW) {
        if (buttonPressTime == 0) buttonPressTime = millis();
        if (millis() - buttonPressTime > 10000) {
            Serial.println("Config button held 10s - starting portal");
            wifiManager.startConfigPortal("UltimateButton-Setup", "12345678");
            buttonPressTime = 0;
        }
    } else {
        buttonPressTime = 0;
    }
}

// ====================== UI ======================
void createFullScreenUI() {
    lv_obj_t * scr = lv_scr_act();
    lv_obj_set_style_bg_color(scr, lv_color_hex(bgColor), 0);

    label = lv_label_create(scr);
    lv_label_set_text(label, buttonText.c_str());
    lv_obj_set_style_text_font(label, &lv_font_montserrat_36, 0);
    lv_obj_set_style_text_color(label, lv_color_hex(textColor), 0);
    lv_obj_center(label);

    statusLabel = lv_label_create(scr);
    lv_obj_align(statusLabel, LV_ALIGN_BOTTOM_MID, 0, -20);
    lv_obj_set_style_text_color(statusLabel, lv_color_hex(0x555555), 0);
    lv_obj_set_style_text_font(statusLabel, &lv_font_montserrat_14, 0);

    lv_obj_add_event_cb(scr, screen_press_cb, LV_EVENT_PRESSED, NULL);
    lv_obj_add_event_cb(scr, screen_release_cb, LV_EVENT_RELEASED, NULL);
}

void screen_press_cb(lv_event_t * e) {
    if (!isTouchPressed) {
        isTouchPressed = true;
        emitInputEvent("press");
    }

    unsigned long now = millis();
    if (now - lastTapTime > TAP_TIMEOUT) tapCount = 1;
    else tapCount++;
    lastTapTime = now;
    lv_obj_set_style_text_opa(label, LV_OPA_70, 0);
}

void screen_release_cb(lv_event_t * e) {
    if (isTouchPressed) {
        isTouchPressed = false;
        emitInputEvent("release");
    }

    lv_obj_set_style_text_opa(label, LV_OPA_100, 0);
}

// ====================== TAP & CONFIG ======================
void handleTap(uint8_t taps) {
    Serial.printf("EVENT: %d Tap%s\n", taps, (taps > 1 ? "s" : ""));
    latestTap.count = taps;
    latestTap.timestamp = millis();

    String json = "{\"event\":\"tap\",\"count\":" + String(taps) +
                  ",\"timestamp\":" + String(latestTap.timestamp) + "}";

    ws.textAll(json);        // still notify any local WebSocket clients
    sendToDirector(json);    // and notify Control4 Director, if connected
}

void emitInputEvent(const char *eventName) {
    unsigned long ts = millis();
    String json = "{\"event\":\"" + String(eventName) + "\",\"timestamp\":" + String(ts) + "}";

    ws.textAll(json);
    sendToDirector(json);
}

// Config helpers (called from /set and from Director commands)
void setBackgroundColor(uint32_t color) {
    bgColor = color;
    lv_obj_set_style_bg_color(lv_scr_act(), lv_color_hex(bgColor), 0);
}

void setTextColor(uint32_t color) {
    textColor = color;
    if (label) lv_obj_set_style_text_color(label, lv_color_hex(textColor), 0);
}

void setBrightness(uint8_t value) {
    brightness = constrain(value, 0, 255);
    amoled.setBrightness(brightness);
}

void updateButtonText(const char* newText) {
    buttonText = newText;
    if (label) lv_label_set_text(label, buttonText.c_str());
}

void updateStatusLabel() {
    if (WiFi.status() == WL_CONNECTED) {
        char buf[128];
        snprintf(buf, sizeof(buf), "Connected: %s | IP: %s", 
                 WiFi.SSID().c_str(), WiFi.localIP().toString().c_str());
        lv_label_set_text(statusLabel, buf);
    } else {
        lv_label_set_text(statusLabel, "WiFi Setup Mode");
    }
}

// ====================== WIFI ======================
void wifiManagerSetup() {
    wifiManager.setConnectTimeout(30);
    wifiManager.setConfigPortalTimeout(180);
    wifiManager.setSaveConfigCallback([]() {
        Serial.println("WiFi saved → Restarting...");
        delay(3000);
        ESP.restart();
    });
    if (!wifiManager.autoConnect("UltimateButton-Setup", "12345678")) {
        Serial.println("WiFi config timeout");
    }
}

// ====================== WEB SERVER + WEBSOCKET (local/debug UI) ======================
void startWebServer() {
    ws.onEvent([](AsyncWebSocket * server, AsyncWebSocketClient * client, 
                  AwsEventType type, void * arg, uint8_t *data, size_t len) {
        if (type == WS_EVT_CONNECT) {
            Serial.printf("WS client #%u connected\n", client->id());
        } else if (type == WS_EVT_DISCONNECT) {
            Serial.printf("WS client #%u disconnected\n", client->id());
        }
    });
    server.addHandler(&ws);

    server.on("/", HTTP_GET, [](AsyncWebServerRequest *request) {
        String html = "<h1>Ultimate Button</h1>";
        html += "<p>Text: " + buttonText + "</p>";
        html += "<p>Brightness: " + String(brightness) + "</p>";
        html += "<p>Hold BOOT button 5s to reconfigure WiFi</p>";
        request->send(200, "text/html", html);
    });

    server.on("/get", HTTP_GET, [](AsyncWebServerRequest *request) {
        String json = "{";
        json += "\"text\":\"" + buttonText + "\",";
        json += "\"brightness\":" + String(brightness) + ",";
        json += "\"bg\":\"" + String(bgColor, HEX) + "\",";
        json += "\"textcol\":\"" + String(textColor, HEX) + "\"";
        json += "}";
        request->send(200, "application/json", json);
    });

    server.on("/set", HTTP_GET, [](AsyncWebServerRequest *request) {
        if (request->hasParam("text")) updateButtonText(request->getParam("text")->value().c_str());
        if (request->hasParam("bg")) setBackgroundColor(strtol(request->getParam("bg")->value().c_str(), NULL, 16));
        if (request->hasParam("textcol")) setTextColor(strtol(request->getParam("textcol")->value().c_str(), NULL, 16));
        if (request->hasParam("bright")) setBrightness(request->getParam("bright")->value().toInt());
        request->send(200, "text/plain", "OK");
    });

    server.begin();
    Serial.println("Web Server + WebSocket ready");
}

// ====================== CONTROL4 DIRECTOR TCP SERVER ======================
// Director opens this connection because driver.xml declares a network
// connection of class TCP on this same port with auto_connect = True.
// Protocol: newline-delimited JSON/text lines, one message per line.

void startDirectorServer() {
    directorServer.onClient([](void *arg, AsyncClient *client) {
        if (directorClient != nullptr && directorClient->connected()) {
            // Director already connected once — reject any second connection.
            Serial.println("Director tried to connect again - rejecting");
            client->close(true);
            return;
        }

        Serial.println("Director connected");
        directorClient = client;
        directorRxBuffer = "";

        client->onData([](void *arg, AsyncClient *c, void *data, size_t len) {
            directorRxBuffer += String((const char *)data).substring(0, len);

            int nl;
            while ((nl = directorRxBuffer.indexOf('\n')) >= 0) {
                String line = directorRxBuffer.substring(0, nl);
                line.trim();
                directorRxBuffer.remove(0, nl + 1);
                if (line.length() > 0) handleDirectorLine(line);
            }
        }, nullptr);

        client->onDisconnect([](void *arg, AsyncClient *c) {
            Serial.println("Director disconnected");
            if (directorClient == c) directorClient = nullptr;
        }, nullptr);

        client->onError([](void *arg, AsyncClient *c, int8_t error) {
            Serial.printf("Director socket error: %d\n", error);
        }, nullptr);
    }, nullptr);

    directorServer.begin();
    Serial.printf("Director TCP server listening on port %u\n", DIRECTOR_PORT);
}

void sendToDirector(const String &line) {
    if (directorClient != nullptr && directorClient->connected()) {
        String out = line + "\n";
        directorClient->add(out.c_str(), out.length());
        directorClient->send();
    }
}

// Very small text protocol for commands coming FROM the driver:
//   TEXT:Some Label
//   BG:RRGGBB
//   TEXTCOL:RRGGBB
//   BRIGHT:0-255
void handleDirectorLine(const String &line) {
    Serial.printf("From Director: %s\n", line.c_str());

    if (line.startsWith("TEXT:")) {
        updateButtonText(line.substring(5).c_str());
    } else if (line.startsWith("BG:")) {
        setBackgroundColor(strtol(line.substring(3).c_str(), NULL, 16));
    } else if (line.startsWith("TEXTCOL:")) {
        setTextColor(strtol(line.substring(8).c_str(), NULL, 16));
    } else if (line.startsWith("BRIGHT:")) {
        setBrightness(line.substring(7).toInt());
    }
}
