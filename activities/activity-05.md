## Add a Property

### driver.xml – Add a Property
1.	Add the code displayed in color to the driver.xml file:
```
<config>
    <script file="driver.lua"/>
    <documentation file = “www/documentation.rtf"></documentation>
```
```xml
    <properties>
        <property>
            <name>Max Number</name>
            <type>RANGED_INTEGER</type>
            <minimum>2</minimum>
            <maximum>20</maximum>
            <default>5</default>
        </property>
    </properties>
```
```
    <commands>
        <command>
```
2.	Save the file.

### driver.lua – Use the Property Value
3.	Modify the GenerateRandomNumber function in the driver.lua file:
```lua
function GenerateRandomNumber()
    local maxNumber = tonumber(Properties['Max Number']) or 2
    local randomNumber = math.random(1, maxNumber)
    C4:SetVariable("RANDOM_NUMBER", randomNumber)
    C4:FireEvent('RandomNumberGenerated')
    print("Generated Random Number: " .. randomNumber)
end
```
4.	Save the file.

### Compile the driver
5.	Use the arrow-up key to repeat the previous instructions to compile the driver.
6.	In Composer Pro, click **Driver > Add or Update Driver or Agent**.
7.	Choose the packaged driver in the compiled folder.

### Test the driver in Composer Pro
8.	Change the property in the driver to a smaller number, such as 10.
9.	Test several times by pressing the scenario button.
