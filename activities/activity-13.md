## Handle "Virtual" Button Presses

If you trigger a button action in Composer Pro, you'd think the proxy could command itself. But this isn't the best way. Your device may need to handle and respond to this action which is why the proxy will only notify your driver and then you handle it from there. In this case, we will handle the notification that a button was "pressed" virtually by calling the same functions when the physical button is pressed.

### `driver.lua` - Send Property Changes to the Ultimate Button Device
1. Add the new handling of the proxy  to `ReceivedFromProxy`:
```lua
if (strCommand == "KEYPAD_BUTTON_ACTION") then 
    local action = tonumber(tParams.ACTION)
    C4:DebugLog("Button action received: " .. tostring(action))
    if (action >= 2) then 
        HandleTap(action - 1)
    else 
        local actionText = "press"
        if (action == 0) then actionText = "release" end
        HandlePressRelease(actionText)
    end
end
```

2. Save the file.

### Compile the Driver
3. Use the **arrow-up** key to repeat the previous instructions to compile the driver.
4. In **Composer Pro**, click **Driver > Add or Update Driver or Agent**.
5. Choose the packaged driver in the **compiled** folder.

### Test the Driver in Composer Pro
6. Update the driver and double click the Ultimate Button in **System Design**.
7. Press the virtual button and confirm that the random number appears on the touchscreen.
