## Create a Command, a Variable, and a Random Number


### driver.xml - Create a Command
1.	In the c4next-driver-development folder, open the random-number-generator/driver.xml file.
2.	Add the code displayed in color to the driver.xml file:
```
<config>
    <script file="driver.lua"/>
    <documentation file = "www/documentation.rtf"></documentation>
```
```xml
    <commands>
        <command>
            <name>GenerateNewNumber</name>
            <description>Generate new random number</description>
            <params/>
        </command>
    </commands>
```
```
</config>
```
3.	Save the file.

### driver.lua – Add a Variable
4.	In the c4next-driver-development folder, open the random-number-generator/driver.lua file.
5.	Modify the OnDriverInit function in the driver.lua file:
```lua
function OnDriverInit ()
    C4:AddVariable("RANDOM_NUMBER", 1, "NUMBER"
end
```

### driver.lua – Code the Command
6.	Modify the ExecuteCommand function in the driver.lua file:
```lua
function ExecuteCommand (strCommand, tParams)
    if strCommand == "GenerateNewNumber" then
        GenerateRandomNumber()
    end
end
```

### driver.lua – Generate the Random Number
7.	Modify the GenerateRandomNumber function in the driver.lua file:
```lua
function GenerateRandomNumber()
    local maxNumber = 20
    local randomNumber = math.random(1, maxNumber)
    C4:SetVariable("RANDOM_NUMBER", randomNumber)
    print("Generated Random Number: " .. randomNumber)
end
```
8.	Save the file.

### Compile the driver
9.	In the integrated terminal, package the driver: 
```
python [path to the driver packager folder]/dp3/driverpackager.py ./ ./../compiled random_number.c4zproj
```
Tip: You can just use the arrow-up key to repeat the previous instructions each time you need to compile the driver.

10.	In Composer Pro, click Driver > Add or Update Driver or Agent.
11.	Choose the packaged driver in the compiled folder.

### Test the driver in Composer Pro
12.	Add a Scenario - Experience Button driver to the Equipment Rack.
13.	Program the button so that when it is selected, the Random Number Generator will receive a Device Specific Command of GenerateNewNumber.
14.	Add the Scenario button to the touchscreen in one of the Navigation menus and Refresh Navigators.
15.	Favorite the button to the Homescreen.
16.	In Composer Pro, navigate to Agents > Variables.
17.	Click Display System Variables and scroll to find the RANDOM_NUMBER variable.
18.	Select the button on the touchscreen and view the variable value change as well as the Last Updated time.
