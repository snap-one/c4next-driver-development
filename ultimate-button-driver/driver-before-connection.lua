
-- TODO: Update the RTF Documentation with Changelog info...

JSON = require ('drivers-common-public.module.json')

require ('drivers-common-public.global.lib')
require ('drivers-common-public.global.timer')
require ('drivers-common-public.global.handlers')

WebSocket = require ('drivers-common-public.module.websocket')

do -- globals
	ESPIP = Properties["IP Address"] or ""
	WSURL = "ws://" .. ESPIP .. "/ws"
	WSCLIENT = nil
end

function OnDriverInit ()

end


function OnDriverLateInit ()
	C4:SendToProxy(5001, "NEW_KEYPAD_BUTTON", {
		SLOTS=6,ENGRAVING="",
		BUTTON_ID=0,
		NAME=Properties["Button Name"],
		ON_COLOR="000000",
		OFF_COLOR="000fff",
		BUTTON_BEHAVIOR=0,
		LED_BEHAVIOR=2
	}, "NOTIFY", false)
	if (Properties["IP Address"] ~= "") then
		-- ConnectWebSocket()
	end

end


function OnVariableChanged(sVariable)

end


function OnPropertyChanged(sProperty)
	print("Property Changed: " .. sProperty .. " to " .. tostring(Properties[sProperty]))
	if (sProperty == "IP Address") then
		SetEspIP()
	end
	if (sProperty == "Button Name") then

	end
	if (sProperty == "Brightness") then

	end
	if (sProperty == "Background Color") then

	end
	if (sProperty == "Text Color") then

	end
end


function ExecuteCommand (strCommand, tParams)

end

function ReceivedFromProxy(idBinding, strCommand, tParams)
 print("ReceivedFromProxy [" .. idBinding .. "]: " .. strCommand)
 if (tParams ~= nil) then
      for ParamName, ParamValue in pairs(tParams) do
           print(ParamName, ParamValue)
      end
 -- if the strCommand="KEYPAD_BUTTON_INFO" and the tParams.BUTTON_ID=0 then change Properties["Button Name"] to tParams.NAME
	if (strCommand == "KEYPAD_BUTTON_INFO") then
		print("updating property")
		C4:UpdateProperty("Button Name", tParams.NAME)
		OnPropertyChanged("Button Name")
	end
 end
end



function RGB2HEX (rgb)
	local hex = ''
	for color in string.gmatch(rgb, "%d+") do
		hex = hex .. string.format ('%02x', color)
	end
	return "0x" ..hex
end


function SetEspIP()
	if (Properties["IP Address"] ~= "") then
		ESPIP = Properties["IP Address"]
		WSURL = "ws://" .. ESPIP .. "/ws"
	end
	-- try and connect to the ESP32 via WebSocket if the response fails or times out after 5 seconds then C4:SendToProxy for ONLINE_CHANGED and set it to false. If successful then set ONLINE_CHANGED to true
	ConnectWebSocket()
end

-- ========================================
-- WEBSOCKET
-- ========================================
function ConnectWebSocket()
    if WSCLIENT then WSCLIENT:Close() end

	if (ESPIP == "") then return end

    WSCLIENT = C4:CreateWebSocket(WSURL, {
        onopen = function()
            C4:DebugLog("WebSocket connected to ESP32")
        end,

        onmessage = function(message)
            local success, data = pcall(C4:JsonDecode, message)
            if success and data and data.event == "tap" then
                HandleTap(data.count)
            end
        end,

        onerror = function(err)
            C4:DebugLog("WebSocket error: " .. tostring(err))
        end,

        onclose = function()
            C4:DebugLog("WebSocket closed - reconnecting in 5s")
            C4:SetTimer(5000, ConnectWebSocket)
        end
    })
end

-- ========================================
-- TAP → KEYPAD PROXY
-- ========================================
function HandleTap(count)
    C4:DebugLog("Tap received: " .. count)

    C4:SendToProxy(5001, "CLICK_COUNT", {
		COUNT = count,
        BUTTON_ID = 0
    })
end
