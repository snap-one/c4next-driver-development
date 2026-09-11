## Modify Button Attributes Using Properties

This activity adds Composer properties for brightness, background color, and text color. Each property is declared in XML and handled in Lua so a change is converted into a protocol command for the Ultimate Button device.

### `driver.xml` - Add Button Properties
1. Add these properties inside the existing `<properties>` element in `driver.xml`:
```xml
<property>
    <name>Brightness</name>
    <default>200</default>
    <type>RANGED_INTEGER</type>
    <minimum>0</minimum>
    <maximum>255</maximum>
    <readonly>false</readonly>
    <tooltip>Set the brightness level of the button (0-255).</tooltip>
</property>
<property>
    <name>Background Color</name>
    <default>255,255,255</default>
    <type>COLOR_SELECTOR</type>
    <readonly>false</readonly>
    <tooltip>Set the color of the button using the color selector.</tooltip>
</property>
<property>
    <name>Text Color</name>
    <default>0,0,0</default>
    <type>COLOR_SELECTOR</type>
    <readonly>false</readonly>
    <tooltip>Set the color of the button using the color selector.</tooltip>
</property>
```

The brightness property accepts values from 0 through 255. The color selector properties store colors as comma-separated RGB values.

2. Save the file.

### `driver.lua` - Send Property Changes to the Ultimate Button Device
3. Add the new cases to `OnPropertyChanged`:
```lua
function OnPropertyChanged(sProperty)
    print("Property Changed: " .. sProperty .. " to " .. tostring(Properties[sProperty]))

    if (sProperty == "Button Name") then
        SendToESP("TEXT:" .. Properties["Button Name"])
    elseif (sProperty == "Brightness") then
        SendToESP("BRIGHT:" .. tostring(Properties["Brightness"]))
    elseif (sProperty == "Background Color") then
        SendToESP("BG:" .. RGB2HEX(Properties["Background Color"]))
    elseif (sProperty == "Text Color") then
        SendToESP("TEXTCOL:" .. RGB2HEX(Properties["Text Color"]))
    end
end
```

`RGB2HEX` converts the Composer RGB value into the hexadecimal format expected by the Ultimate Button device. The resulting commands are `BRIGHT:`, `BG:`, and `TEXTCOL:`.

4. Save the file.

### Compile the Driver
5. Use the **arrow-up** key to repeat the previous instructions to compile the driver.
6. In **Composer Pro**, click **Driver > Add or Update Driver or Agent**.
7. Choose the packaged driver in the **compiled** folder.

### Test the Driver in Composer Pro
8. Update the driver and open its Properties.
9. Change **Brightness**, **Background Color**, and **Text Color** one at a time.
10. Confirm that the Ultimate Button device receives the corresponding protocol command and that the button display changes.