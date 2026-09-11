## Send the Button Name from the Proxy to the Ultimate Button Device

This activity adds two-way handling for the button name. When the driver property changes, Lua sends a `TEXT:` command to the Ultimate Button device. When the keypad proxy reports a new name, Lua updates the driver property and sends the same command to the Ultimate Button device.

### `driver.lua` - Send the Name to the Ultimate Button Device
1. Modify `OnPropertyChanged` in the `driver.lua` file:
```lua
function OnPropertyChanged(sProperty)
	print("Property Changed: " .. sProperty .. " to " .. tostring(Properties[sProperty]))

	if (sProperty == "Button Name") then
		SendToESP("TEXT:" .. Properties["Button Name"])
	end
end
```

2. Update `ReceivedFromProxy` so it handles the `KEYPAD_BUTTON_INFO` command:
```lua
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
```

The call to `OnPropertyChanged` makes sure that a name received from the proxy is also sent to the Ultimate Button device.

3. Save the file.

### Compile the Driver
4. Use the **arrow-up** key to repeat the previous instructions to compile the driver.
5. In **Composer Pro**, click **Driver > Add or Update Driver or Agent**.
6. Choose the packaged driver in the **compiled** folder.

### Test the Driver in Composer Pro
7. Open the **Lua** tab in the **Advanced Properties** of the Ultimate Button device.
8. Change the button name through the keypad proxy.
9. Confirm that the driver receives the `KEYPAD_BUTTON_INFO` command and that the Ultimate Button device text changed.