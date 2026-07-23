-- ========================================
-- CONSTANTS
-- ========================================
NETWORK_BINDING_ID = 6001   -- must match the <id> of the network <connection> in driver.xml
KEYPAD_BINDING_ID  = 5001 -- must match the id of the proxy <connection> in driver.xml
NETWORK_PORT = 1000   -- must match the <number> of the network <port> in driver.xml

-- Buffer for reassembling newline-delimited messages from the ESP32.
-- TCP doesn't guarantee that one Send on the device arrives as one
-- ReceivedFromNetwork call on this side, so we accumulate and split on "\n".
NetRxBuffer = ""


-- ========================================
-- DRIVER LIFECYCLE
-- ========================================
function OnDriverInit()
end

function OnDriverLateInit()
	local buttonName = Properties["Button Name"]

	C4:SendToProxy(KEYPAD_BINDING_ID, "NEW_KEYPAD_BUTTON", {
		SLOTS = 6,
		ENGRAVING = "",
		BUTTON_ID = 0,
		NAME = buttonName,
		ON_COLOR = "000000",
		OFF_COLOR = "000fff",
		BUTTON_BEHAVIOR = 0,
		LED_BEHAVIOR = 2
	}, "NOTIFY", false)

	-- No manual connection needed here: the network connection in driver.xml
	-- has auto_connect/keep_connection set, so Director opens and maintains
	-- the TCP session to whatever IP is bound in Composer Pro's
	-- Connections > Network tab. We just react to it below.
end


-- ========================================
-- PROPERTIES
-- ========================================
function OnPropertyChanged(sProperty)
	print("Property Changed: " .. sProperty .. " to " .. tostring(Properties[sProperty]))

	if (sProperty == "Button Name") then
		SendToESP("TEXT:" .. Properties["Button Name"])
	local buttonName = Properties["Button Name"]

	C4:SendToProxy(KEYPAD_BINDING_ID, "KEYPAD_BUTTON_INFO", {
		BUTTON_ID = 0,
		NAME = buttonName
	}, "NOTIFY", false)


	elseif (sProperty == "Brightness") then
		SendToESP("BRIGHT:" .. tostring(Properties["Brightness"]))

	elseif (sProperty == "Background Color") then
		SendToESP("BG:" .. RGB2HEX(Properties["Background Color"]))

	elseif (sProperty == "Text Color") then
		SendToESP("TEXTCOL:" .. RGB2HEX(Properties["Text Color"]))
	end
end


-- ========================================
-- PROXY (KEYPAD)
-- ========================================

function ReceivedFromProxy(idBinding, strCommand, tParams)
	print("ReceivedFromProxy [" .. idBinding .. "]: " .. strCommand)

	if (tParams ~= nil) then
		for ParamName, ParamValue in pairs(tParams) do
			print(ParamName, ParamValue)
		end

		if (strCommand == "KEYPAD_BUTTON_INFO" and tParams.NAME ~= nil) then
			print("updating property")
			C4:UpdateProperty("Button Name", tParams.NAME)
			OnPropertyChanged("Button Name")
		end
	end
end


-- ========================================
-- NETWORK (ESP32 over bound TCP connection)
-- ========================================
function OnConnectionStatusChanged(idBinding, strClass, bIsConnected)
	if (idBinding ~= NETWORK_BINDING_ID) then return end

	if (bIsConnected) then
		C4:DebugLog("ESP32 button connected")
		NetRxBuffer = ""
		SyncDeviceState()   -- push current properties so the device matches Composer after (re)connect
	else
		C4:DebugLog("ESP32 button disconnected")
	end
end

function ReceivedFromNetwork(idBinding, port, strData)
	if (idBinding ~= NETWORK_BINDING_ID) then return end

	NetRxBuffer = NetRxBuffer .. strData
	print("Received from network: " .. strData)
	local newlinePos = NetRxBuffer:find("\n")
	while (newlinePos ~= nil) do
		local line = NetRxBuffer:sub(1, newlinePos - 1)
		NetRxBuffer = NetRxBuffer:sub(newlinePos + 1)

		HandleLineFromESP(line)

		newlinePos = NetRxBuffer:find("\n")
	end
end

function HandleLineFromESP(strLine)
	local ok, data = pcall(function()
		return C4:JsonDecode(strLine)
	end)
	if (not ok or data == nil) then
		C4:DebugLog("Ignoring unparsable line from ESP32: " .. strLine)
		return
	end

	if (data.event == "tap") then
		HandleTap(data.count)
	end

	if (data.event == "press" or data.event == "release") then 
		HandlePressRelease(data.event)
	end

end

function SendToESP(strLine)
	C4:SendToNetwork(NETWORK_BINDING_ID, NETWORK_PORT, strLine .. "\n")
end

-- Re-sends current property values to the device, e.g. right after it
-- (re)connects, so display state always matches what's set in Composer.
function SyncDeviceState()
	SendToESP("TEXT:" .. tostring(Properties["Button Name"]))
	SendToESP("BRIGHT:" .. tostring(Properties["Brightness"]))
	SendToESP("BG:" .. RGB2HEX(Properties["Background Color"]))
	SendToESP("TEXTCOL:" .. RGB2HEX(Properties["Text Color"]))
end


function HandleTap(count)
	C4:DebugLog("Button tapped " .. tostring(count) .. " times")
	C4:SendToProxy(KEYPAD_BINDING_ID, "CLICK_COUNT", {
		COUNT = count,
		BUTTON_ID = 0
	})
end

function HandlePressRelease(event)
	local action = 0
	if (event == "press") then
		action = 1
	end
	C4:DebugLog("Button " .. tostring(event))
	C4:SendToProxy(KEYPAD_BINDING_ID, "KEYPAD_BUTTON_ACTION", {
		ACTION = action,
		BUTTON_ID = 0
	})
end

-- ========================================
-- HELPERS
-- ========================================
-- Converts a Composer color property formatted as "R,G,B" into a plain
-- hex string, e.g. "255,0,0" -> "FF0000"
function RGB2HEX(rgb)
	local hex = ''
	for component in string.gmatch(rgb, "%d+") do
		hex = hex .. string.format('%02X', tonumber(component))
	end
	return hex
end