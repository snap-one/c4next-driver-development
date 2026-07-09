
-- TODO: Update the RTF Documentation with Changelog info...

do -- globals
	PROXY_CMDS = {}
	EX_CMDS = {}
	ON_PROPERTY_CHANGED = {}
	TOGGLE_STATE = TOGGLE_STATE or false
	LED = LED or {}
	LED ['On'] = LED ['On'] or '000000'
	LED ['Off'] = LED ['Off'] or '000000'
	LED ['Pressed'] = LED ['Pressed'] or '000000'
	
	STATE_NAME = STATE_NAME or {}
	STATE_NAME ['Selected'] = 'On'
	STATE_NAME ['Default'] = 'Off'
	DECADE_NAME = 'ancient'
end

function OnDriverInit ()
	C4:UpdateProperty ('Driver Version', C4:GetDriverConfigInfo ("version"))
	OnPropertyChanged('On LED Color')
	OnPropertyChanged('Off LED Color')
	OnPropertyChanged('Toggle State Each Time Selected')
end


function OnDriverLateInit ()
	local strState = PersistGetValue('strState') or ''
	local strDecade = Properties['Decade'] or DECADE_NAME
	C4:AddVariable("STATE", strState, "STRING") -- String variable of the state

	STATE = PersistGetValue('bState') or false -- Boolean value of the state true = On, false = Off
	local initializing = true
	DisplayState (STATE, initializing)
end


function OnVariableChanged(sVariable)
	if (sVariable == "STATE") then
		local strValue = Variables[sVariable] or ''
		PersistSetValue('strState', strValue)
		
		local tStates = {
			On = true,
			Off = false,
		}
		local state = tStates[ Variables[sVariable] ]
		if (state ~= nil) then  -- Valid values that will control the uibutton are "On" and "Off"
			STATE = state
			DisplayState (state)
		end
	end
end


function OnPropertyChanged(sProperty)

	local propertyValue = Properties[sProperty]

	-- Remove any spaces (trim the property)
	local trimmedProperty = string.gsub(sProperty, " ", "")

	-- if function exists then execute (non-stripped)
	if (ON_PROPERTY_CHANGED[sProperty] ~= nil and type(ON_PROPERTY_CHANGED[sProperty]) == "function") then
		ON_PROPERTY_CHANGED[sProperty](propertyValue)
		return
	-- elseif trimmed function exists then execute
	elseif (ON_PROPERTY_CHANGED[trimmedProperty] ~= nil and type(ON_PROPERTY_CHANGED[trimmedProperty]) == "function") then
		ON_PROPERTY_CHANGED[trimmedProperty](propertyValue)
		return
	end
end

function ON_PROPERTY_CHANGED.ToggleStateEachTimeSelected (value)
	TOGGLE_STATE = (value == 'Yes')
end

function ON_PROPERTY_CHANGED.OnLEDColor (value)
	LED ['On'] = RGB2HEX (value)
	C4:SendToProxy(500, "BUTTON_COLORS", {ON_COLOR = {COLOR_STR = LED ['On']}, OFF_COLOR = {COLOR_STR = LED ['Off']}}, "NOTIFY")
	C4:SendToProxy(501, "BUTTON_COLORS", {ON_COLOR = {COLOR_STR = LED ['On']}, OFF_COLOR = {COLOR_STR = '000000'}}, "NOTIFY")
end

function ON_PROPERTY_CHANGED.OffLEDColor (value)
	LED ['Off'] = RGB2HEX (value)
	C4:SendToProxy(500, "BUTTON_COLORS", {ON_COLOR = {COLOR_STR = LED ['On']}, OFF_COLOR = {COLOR_STR = LED ['Off']}}, "NOTIFY")
	C4:SendToProxy(502, "BUTTON_COLORS", {ON_COLOR = {COLOR_STR = LED ['Off']}, OFF_COLOR = {COLOR_STR = '000000'}}, "NOTIFY")
end

function ON_PROPERTY_CHANGED.Decade (value)
	DECADE_NAME = value
	local initializing = true
	DisplayState (STATE, initializing)
end

function ExecuteCommand (strCommand, tParams)
    if EX_CMDS and type(EX_CMDS[strCommand]) == "function" then
            EX_CMDS[strCommand](tParams)
    elseif strCommand == "LUA_ACTION" then
        if tParams ~= nil then
            for cmd, cmdv in pairs(tParams) do
                print (cmd,cmdv)
                if cmd == "ACTION" then
                    if ACTIONS and type(ACTIONS[cmdv]) == "function" then
                        ACTIONS[cmdv](tParams)
                    else
                        print("From ExecuteCommand Function - Undefined Action")
                        print("Key: " .. cmd .. " Value: " .. cmdv)
                    end
                else
                    print("From ExecuteCommand Function - Undefined ACTION")
                    print("Key: " .. cmd .. " Value: " .. cmdv)
                end
            end
        end
    end
end

function ReceivedFromProxy (idBinding, strCommand, tParams)
    if type(PROXY_CMDS[strCommand]) == "function" then
        local success, retVal = pcall(PROXY_CMDS[strCommand], tParams, idBinding)
        if success then
            return retVal
        end
    end
    return nil
end

function PROXY_CMDS.DO_CLICK (tParams, idBinding)
	if (idBinding == 500) then
		-- Toggle button click acts like UI button pressed
		PROXY_CMDS.SELECT (tParams)

	elseif (idBinding == 501) then
		STATE = true
		DisplayState (STATE)

	elseif (idBinding == 502) then
		STATE = false
		DisplayState (STATE)

	else
		print ('Unhandled binding ' .. idBinding)
	end
end

function PROXY_CMDS.REQUEST_BUTTON_COLORS (tParams, idBinding)
	if (idBinding == 500) then
		C4:SendToProxy(500, "BUTTON_COLORS", {ON_COLOR = {COLOR_STR = LED ['On']}, OFF_COLOR = {COLOR_STR = LED ['Off']}}, "NOTIFY")

	elseif (idBinding == 501) then
		C4:SendToProxy(501, "BUTTON_COLORS", {ON_COLOR = {COLOR_STR = LED ['On']}, OFF_COLOR = {COLOR_STR = '000000'}}, "NOTIFY")

	elseif (idBinding == 502) then
		C4:SendToProxy(502, "BUTTON_COLORS", {ON_COLOR = {COLOR_STR = LED ['Off']}, OFF_COLOR = {COLOR_STR = '000000'}}, "NOTIFY")

	else
		print ('Unhandled binding ' .. idBinding)
	end
end

function PROXY_CMDS.SELECT (tParams, idBinding)
	if TOGGLE_STATE then
		STATE = not STATE
		DisplayState (STATE)
	end

end

function EX_CMDS.SetState (tParams)
	STATE = (tParams.State == 'On')
	DisplayState (STATE)
end

function EX_CMDS.ToggleState (tParams)
  PROXY_CMDS.SELECT (tParams)
end

function DisplayState (state, initializing)
	local curPersistState = PersistGetValue('bState')
	if (state ~= curPersistState or initializing) then
		PersistSetValue('bState', state)
		local curState
	
		if state then
			curState = STATE_NAME["Selected"]
			local on = Properties['On Name']
			C4:SendToProxy(5001, "ICON_CHANGED", {icon = 'Selected' .. DECADE_NAME, icon_description = on})
			if (not initializing) then -- Don't fire the event if the driver is initializing
				C4:FireEvent('On')
			end
			C4:SendToProxy (500, 'MATCH_LED_STATE', {STATE = '1'})
			C4:SendToProxy (501, 'MATCH_LED_STATE', {STATE = '1'})
			C4:SendToProxy (502, 'MATCH_LED_STATE', {STATE = '0'})
		else
			curState = STATE_NAME["Default"]
			local off = Properties['Off Name']
			C4:SendToProxy(5001, "ICON_CHANGED", {icon = 'Default' .. DECADE_NAME, icon_description = off})
			if (not initializing) then
				C4:FireEvent('Off')
			end
			C4:SendToProxy (500, 'MATCH_LED_STATE', {STATE = '0'})
			C4:SendToProxy (502, 'MATCH_LED_STATE', {STATE = '1'})
			C4:SendToProxy (501, 'MATCH_LED_STATE', {STATE = '0'})
		end
	
		C4:SetVariable("STATE", curState)
		C4:UpdateProperty ('Current State', curState)
		PersistSetValue('strState', curState)
	end
end

function RGB2HEX (rgb)
	local hex = ''
	for color in string.gmatch(rgb, "%d+") do
		hex = hex .. string.format ('%02x', color)
	end
	return hex
end


-- COMMON_LIB_VER = 26
-- Persist functions from drivers-common-public library located at https://github.com/control4/drivers-common-public/blob/master/global/lib.lua#L809
function PersistSetValue (key, value, encrypted)
	if (encrypted == nil) then
		encrypted = false
	end

	if (C4.PersistSetValue) then
		C4:PersistSetValue (key, value, encrypted)
	else
		PersistData = PersistData or {}
		PersistData.LibValueStore = PersistData.LibValueStore or {}
		PersistData.LibValueStore [key] = value
	end
end

function PersistGetValue (key, encrypted)
	if (encrypted == nil) then
		encrypted = false
	end

	local value

	if (C4.PersistGetValue) then
		value = C4:PersistGetValue (key, encrypted)
		if (value == nil and encrypted == true) then
			value = C4:PersistGetValue (key, false)
			if (value ~= nil) then
				PersistSetValue (key, value, encrypted)
			end
		end
		if (value == nil) then
			if (PersistData and PersistData.LibValueStore and PersistData.LibValueStore [key]) then
				value = PersistData.LibValueStore [key]
				PersistSetValue (key, value, encrypted)
				PersistData.LibValueStore [key] = nil
				if (next (PersistData.LibValueStore) == nil) then
					PersistData.LibValueStore = nil
				end
			end
		end
	elseif (PersistData and PersistData.LibValueStore and PersistData.LibValueStore [key]) then
		value = PersistData.LibValueStore [key]
	end
	return value
end

function PersistDeleteValue (key)
	if (C4.PersistDeleteValue) then
		C4:PersistDeleteValue (key)
	else
		if (PersistData and PersistData.LibValueStore) then
			PersistData.LibValueStore [key] = nil
			if (next (PersistData.LibValueStore) == nil) then
				PersistData.LibValueStore = nil
			end
		end
	end
end

