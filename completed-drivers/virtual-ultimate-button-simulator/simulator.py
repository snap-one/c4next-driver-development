import json
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from socketserver import StreamRequestHandler, ThreadingTCPServer

TCP_HOST = "0.0.0.0"
TCP_PORT = 10000
HTTP_HOST = "127.0.0.1"
HTTP_PORT = 8080

PAGE = """<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Virtual Ultimate Button</title>
  <style>
    :root {
      color-scheme: light;
      font-family: ui-rounded, "Avenir Next", Avenir, sans-serif;
      color: #202b2b;
      background: #edf1ed;
    }
    * { box-sizing: border-box; }
    body {
      min-height: 100vh;
      margin: 0;
      padding: 28px 18px;
      background: radial-gradient(circle at 15% 10%, #fff 0, #edf1ed 42%, #e3e9e5 100%);
    }
    main { width: min(680px, 100%); margin: 0 auto; }
    header { display: flex; align-items: center; justify-content: space-between; gap: 16px; }
    .eyebrow { margin: 0 0 5px; color: #60706e; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; }
    h1 { margin: 0; font-size: 25px; font-weight: 750; }
    .connection {
      display: inline-flex; align-items: center; gap: 8px; white-space: nowrap;
      padding: 9px 12px; border: 1px solid #ccd5d0; border-radius: 999px;
      background: #f8faf8; color: #485653; font-size: 13px;
    }
    .dot { width: 9px; height: 9px; border-radius: 50%; background: #bd6b35; }
    .connection.online .dot { background: #268369; }
    .stage {
      margin-top: 30px; padding: 24px; border: 1px solid #d3dbd6; border-radius: 8px;
      background: rgba(250, 252, 250, .82); box-shadow: 0 14px 38px rgba(36, 55, 48, .08);
    }
    .stage-label { margin: 0 0 18px; color: #60706e; font-size: 12px; font-weight: 700; }
    .pad-wrap { display: grid; place-items: center; min-height: 300px; }
    #pad {
      width: min(100%, 380px); min-height: 240px; padding: 28px;
      border: 1px solid rgba(0, 0, 0, .12); border-radius: 12px;
      color: #111; background: #fff; box-shadow: 0 9px 0 rgba(25, 39, 35, .18), 0 18px 28px rgba(25, 39, 35, .12);
      font: inherit; font-size: 30px; font-weight: 750; overflow-wrap: anywhere;
      touch-action: none; user-select: none; cursor: pointer; transition: transform 80ms ease, box-shadow 80ms ease;
    }
    #pad:active, #pad.pressed { transform: translateY(7px); box-shadow: 0 2px 0 rgba(25, 39, 35, .18), 0 8px 14px rgba(25, 39, 35, .1); }
    .hint { margin: 13px 0 0; color: #667471; text-align: center; font-size: 13px; }
    footer { display: flex; justify-content: space-between; gap: 12px; margin-top: 20px; color: #687572; font-size: 12px; }
    #message { min-height: 1em; color: #a44732; }
    @media (max-width: 480px) {
      body { padding: 20px 12px; }
      header { align-items: flex-start; flex-direction: column; }
      .stage { margin-top: 22px; padding: 18px 14px; }
      .pad-wrap { min-height: 260px; }
      #pad { min-height: 210px; font-size: 25px; }
      footer { flex-direction: column; }
    }
  </style>
</head>
<body>
  <main>
    <header>
      <div><p class="eyebrow">CONTROL4 DRIVER TEST</p><h1>Virtual Ultimate Button</h1></div>
      <div id="connection" class="connection"><span class="dot"></span><span id="connection-text">Waiting for driver</span></div>
    </header>
    <section class="stage" aria-label="Button simulator">
      <p class="stage-label">SIMULATED DEVICE</p>
      <div class="pad-wrap"><button id="pad" type="button">Ultimate Button</button></div>
      <p class="hint">Tap for a click; press and hold for a button press.</p>
      <footer><span id="appearance">Brightness: 200</span><span id="message" role="status"></span></footer>
    </section>
  </main>
  <script>
    const pad = document.getElementById('pad');
    const connection = document.getElementById('connection');
    const connectionText = document.getElementById('connection-text');
    const message = document.getElementById('message');
    const appearance = document.getElementById('appearance');
    const tapWindowMs = 250;
    let pointerId = null;
    let pressStartedAt = 0;
    let pendingTapCount = 0;
    let tapTimer = null;
    let eventQueue = Promise.resolve();

    function sendEvent(event, count) {
      eventQueue = eventQueue.then(async () => {
        const response = await fetch('/api/event', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ event, count })
        });
        const result = await response.json();
        if (!response.ok) throw new Error(result.error || 'Could not send event');
        message.textContent = '';
      }).catch((error) => {
        message.textContent = error.message;
      });
      return eventQueue;
    }

    async function refreshState() {
      try {
        const response = await fetch('/api/state', { cache: 'no-store' });
        const state = await response.json();
        connection.classList.toggle('online', state.connected);
        connectionText.textContent = state.connected ? 'Driver connected' : 'Waiting for driver';
        pad.textContent = state.button_name || 'Ultimate Button';
        pad.style.backgroundColor = state.background;
        pad.style.color = state.text_color;
        pad.style.filter = `brightness(${0.35 + 0.65 * state.brightness / 255})`;
        appearance.textContent = `Brightness: ${state.brightness} · Background: ${state.background} · Text: ${state.text_color}`;
      } catch (error) {
        connection.classList.remove('online');
        connectionText.textContent = 'Simulator unavailable';
      }
    }

    pad.addEventListener('pointerdown', (event) => {
      if (pointerId !== null) return;
      event.preventDefault();
      pointerId = event.pointerId;
      pressStartedAt = Date.now();
      pad.classList.add('pressed');
      pad.setPointerCapture(pointerId);
      sendEvent('press');
    });

    pad.addEventListener('pointerup', (event) => {
      if (event.pointerId !== pointerId) return;
      event.preventDefault();
      pointerId = null;
      pad.classList.remove('pressed');
      sendEvent('release');
      if (Date.now() - pressStartedAt <= 600) {
        pendingTapCount += 1;
        clearTimeout(tapTimer);
        tapTimer = setTimeout(() => {
          sendEvent('tap', pendingTapCount);
          pendingTapCount = 0;
        }, tapWindowMs);
      }
    });

    pad.addEventListener('pointercancel', (event) => {
      if (event.pointerId !== pointerId) return;
      pointerId = null;
      pad.classList.remove('pressed');
      sendEvent('release');
    });

    setInterval(refreshState, 700);
    refreshState();
  </script>
</body>
</html>
"""


class SimulatorState:
    def __init__(self):
        self.lock = threading.RLock()
        self.client = None
        self.button_name = "Ultimate Button"
        self.brightness = 200
        self.background = "#FFFFFF"
        self.text_color = "#000000"

    def set_client(self, client):
        with self.lock:
            self.client = client

    def clear_client(self, client):
        with self.lock:
            if self.client is client:
                self.client = None

    def update_from_driver(self, line):
        command, separator, value = line.partition(":")
        if not separator:
            return

        with self.lock:
            if command == "TEXT":
                self.button_name = value[:100]
            elif command == "BRIGHT":
                try:
                    self.brightness = max(0, min(255, int(value)))
                except ValueError:
                    return
            elif command in ("BG", "TEXTCOL"):
                color = value.strip().removeprefix("#")
                if len(color) != 6 or any(char not in "0123456789abcdefABCDEF" for char in color):
                    return
                if command == "BG":
                    self.background = "#" + color.upper()
                else:
                    self.text_color = "#" + color.upper()

    def snapshot(self):
        with self.lock:
            return {
                "connected": self.client is not None,
                "button_name": self.button_name,
                "brightness": self.brightness,
                "background": self.background,
                "text_color": self.text_color,
            }

    def send_event(self, event, count=None):
        payload = {"event": event, "timestamp": int(time.monotonic() * 1000)}
        if event == "tap":
            payload["count"] = count
        encoded = (json.dumps(payload, separators=(",", ":")) + "\n").encode("utf-8")

        with self.lock:
            client = self.client
            if client is None:
                return False
            try:
                client.sendall(encoded)
                return True
            except OSError:
                self.client = None
                return False


state = SimulatorState()


class DriverHandler(StreamRequestHandler):
    def handle(self):
        state.set_client(self.request)
        print(f"Control4 driver connected from {self.client_address[0]}")
        try:
            while True:
                raw_line = self.rfile.readline()
                if not raw_line:
                    break
                line = raw_line.decode("utf-8", errors="replace").rstrip("\r\n")
                state.update_from_driver(line)
        finally:
            state.clear_client(self.request)
            print(f"Control4 driver disconnected from {self.client_address[0]}")


class DriverTCPServer(ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True


class WebHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/":
            body = PAGE.encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return

        if self.path == "/api/state":
            self.send_json(200, state.snapshot())
            return

        self.send_json(404, {"error": "Not found"})

    def do_POST(self):
        if self.path != "/api/event":
            self.send_json(404, {"error": "Not found"})
            return

        try:
            length = int(self.headers.get("Content-Length", "0"))
            if length > 1024:
                raise ValueError("Request too large")
            payload = json.loads(self.rfile.read(length))
            event = payload.get("event")
            if event not in ("tap", "press", "release"):
                raise ValueError("Unsupported event")
            count = None
            if event == "tap":
                count = int(payload.get("count", 1))
                if not 1 <= count <= 10:
                    raise ValueError("Tap count must be from 1 to 10")
        except (ValueError, TypeError, json.JSONDecodeError) as error:
            self.send_json(400, {"error": str(error)})
            return

        if not state.send_event(event, count):
            self.send_json(503, {"error": "Connect the driver to this simulator first"})
            return
        self.send_json(200, {"sent": True})

    def send_json(self, status, value):
        body = json.dumps(value).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format_string, *args):
        pass


class WebServer(ThreadingHTTPServer):
    daemon_threads = True


def main():
    tcp_server = DriverTCPServer((TCP_HOST, TCP_PORT), DriverHandler)
    web_server = WebServer((HTTP_HOST, HTTP_PORT), WebHandler)
    tcp_thread = threading.Thread(target=tcp_server.serve_forever, daemon=True)
    tcp_thread.start()

    print(f"Simulator TCP endpoint listening on {TCP_HOST}:{TCP_PORT}")
    print(f"Open the simulator UI on this laptop: http://{HTTP_HOST}:{HTTP_PORT}")
    try:
        web_server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping simulator...")
    finally:
        web_server.server_close()
        tcp_server.shutdown()
        tcp_server.server_close()


if __name__ == "__main__":
    main()
