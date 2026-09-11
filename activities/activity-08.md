## Set Up the Keypad Proxy and Capabilities

This activity changes the driver from a basic driver with an unconfigured proxy into a driver that exposes an Ultimate Button through the Control4 keypad proxy. The XML declares the proxy, its capabilities, and its `KEYPAD` connection. The Lua code creates the button when the driver starts.

### `driver.xml` - Configure the Keypad Proxy
1. In the `driver.xml` file, replace the existing proxy element:
```xml
<proxy name="ultimate_button">Ultimate Button</proxy>
```

with:
```xml
<proxy proxybindingid="5001" name="Ultimate Button" primary="True">keypad_proxy</proxy>
```

The `proxybindingid` value will match the keypad connection ID and the Lua binding ID added later.

2. Add the following capability elements inside the existing `<capabilities>` element:
```xml
<capabilities>
    <has_leds>False</has_leds>
    <leds_have_color>False</leds_have_color>
    <push_release_support>False</push_release_support>
    <click_support>True</click_support>
    <multi_click_support>True</multi_click_support>
    <fully_customizable>False</fully_customizable>
    <engravable>False</engravable>
    <custom_finishes>False</custom_finishes>
    <hide_proxy_properties>False</hide_proxy_properties>
    <button_behavior>False</button_behavior>
    <led_behavior>False</led_behavior>
    <has_load>False</has_load>
    <columns>1</columns>
    <rows>6</rows>
</capabilities>
```

These values describe the keypad proxy: it supports clicks and multi-clicks, has one column, and provides six button slots.

3. Add this connection inside the existing `<connections>` element:
```xml
<connection>
    <id>5001</id>
    <facing>6</facing>
    <connectionname>Keypad</connectionname>
    <type>2</type>
    <consumer>False</consumer>
    <audiosource>False</audiosource>
    <videosource>False</videosource>
    <linelevel>False</linelevel>
    <classes>
        <class>
            <autobind>True</autobind>
            <classname>KEYPAD</classname>
        </class>
    </classes>
</connection>
```

The connection ID `5001` matches the proxy binding ID and will be used by the Lua driver when it communicates with the keypad proxy.

4. Save the file.

### `driver.lua` - Create the Keypad Button
5. Add the keypad binding constant with the other constants at the top of the `driver.lua` file:
```lua
PROXY_BINDING_ID = 5001 -- must match the id of the proxy <connection> in driver.xml
```

6. Modify `OnDriverLateInit` so it creates a six-slot keypad button:


```lua
function OnDriverLateInit()
    local buttonName = Properties["Button Name"]

    C4:SendToProxy(PROXY_BINDING_ID, "NEW_KEYPAD_BUTTON", {
        SLOTS = 6,
        ENGRAVING = "",
        BUTTON_ID = 0,
        NAME = buttonName,
        ON_COLOR = "000000",
        OFF_COLOR = "000fff",
        BUTTON_BEHAVIOR = 0,
        LED_BEHAVIOR = 2
    }, "NOTIFY", false)
end
```

7. Save the file.

### Compile the Driver
8. Use the **arrow-up** key to repeat the previous instructions to compile the driver.
9. In **Composer Pro**, click **Driver > Add or Update Driver or Agent**.
10. Choose the packaged driver in the **compiled** folder.

### View the Driver in Composer Pro
11. Add the driver to any room in the project.
12. View the configuration options in the **Properties** and **Advanced Properties**. What is available through the proxy?
13. Look at the available options in **Programming** for the device as well. What programming is available through the proxy?
