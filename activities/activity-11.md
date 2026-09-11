## Send Events from the Ultimate Button device to the Keypad Proxy

This activity sends device state and button events from the protocol side to the Control4 keypad proxy. The driver forwards name updates, tap counts, and press or release actions so Composer can use them for keypad behavior and programming.

### `driver.lua` - Send Proxy Notifications
1. In `ReceivedFromProxy`, notify the keypad proxy when a button name is received:
```lua
if (strCommand == "KEYPAD_BUTTON_INFO" and tParams.NAME ~= nil) then
    print("updating property")

    C4:SendToProxy(PROXY_BINDING_ID, "KEYPAD_BUTTON_INFO", {
        BUTTON_ID = 0,
        NAME = tParams.NAME
    }, "NOTIFY", false)

    C4:UpdateProperty("Button Name", tParams.NAME)
    OnPropertyChanged("Button Name")
end
```

2. Modify `HandleTap` so the tap count is sent to the keypad proxy:
```lua
function HandleTap(count)
    C4:DebugLog("Button tapped " .. tostring(count) .. " times")
    C4:SendToProxy(PROXY_BINDING_ID, "CLICK_COUNT", {
        COUNT = count,
        BUTTON_ID = 0
    })
end
```

3. Modify `HandlePressRelease` so the proxy receives the current button action:
```lua
function HandlePressRelease(event)
    local action = 0
    if (event == "press") then
        action = 1
    end
    C4:DebugLog("Button " .. tostring(event))
    C4:SendToProxy(PROXY_BINDING_ID, "KEYPAD_BUTTON_ACTION", {
        ACTION = action,
        BUTTON_ID = 0
    })
end
```

The keypad protocol uses `ACTION = 1` for press and `ACTION = 0` for release. The `BUTTON_ID` value identifies the first button created in `OnDriverLateInit`.

4. Save the file.

### Compile the Driver
5. Use the **arrow-up** key to repeat the previous instructions to compile the driver.
6. In **Composer Pro**, click **Driver > Add or Update Driver or Agent**.
7. Choose the packaged driver in the **compiled** folder.

### Test the Driver in Composer Pro
8. Add an event for the Ultimate Button so that a new random number is generated when the Ultimate Button is tapped a single time.
9. Open the **Lua** tab in the **Advanced Properties** of the Ultimate Button device.
10. Tap the Ultimate Button and confirm that the keypad proxy receives the press and release actions as well as a random number is displayed on the touchscreen.
