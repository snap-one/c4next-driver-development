## Create an Action

### driver.xml - Create an Action
1.	Add the code in color to the driver.xml file:
```
<config>
    <script file="driver.lua"/>
    <documentation file = "www/documentation.rtf"></documentation>
```
```xml
    <actions>
        <action>
            <name>Generate New Number</name>
            <command>GenerateNewNumber</command>
            <params/>
        </action>
    </actions>
```
```
    <properties>
```
2.	Save the file.

### driver.lua - Create an Action
3.	Modify the Executecommand function in the driver.lua file:
```lua
function ExecuteCommand (strCommand, tParams)
    if strCommand == "GenerateNewNumber" or (strCommand == "LUA_ACTION" and tParams.ACTION == "GenerateNewNumber") then 
        GenerateRandomNumber()
    end
end
```
4.	Save the file.

### Compile the driver
5.	Use the arrow-up key to repeat the previous instructions to compile the driver.
6.	In Composer Pro, click **Driver > Add or Update Driver or Agent**.
7.	Choose the packaged driver in the compiled folder.

### Test the driver in Composer Pro
8.	Use the action in the driver to test if the event fires.

