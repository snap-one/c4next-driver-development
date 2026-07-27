## Create an Event

### driver.xml - Create an Event
1.	Add the code displayed in color to the driver.xml file:
```
    <proxies>
        <proxy name="random_number_generator">Random Number</proxy>
    </proxies>
```
```xml
    <events>
        <event>
            <id>1</id>
            <name>RandomNumberGenerated</name>
            <description>When a new number is generated</description>
        </event>
    </events>
```
```
</devicedata>
```
2.	Save the file.

### driver.lua - Create an Event
3.	Modify the GenerateRandomNumber function in the driver.lua file:
```lua
function GenerateRandomNumber()
    local maxNumber = 20
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
8.	Create an announcement that displays the value of the RANDOM_NUMBER variable. 
9.	Program the announcement to execute when the RandomNumberGenerated event is fired.
10.	Select the button on the touchscreen and view the variable value change on the touchscreen.
