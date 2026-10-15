## Modify an Existing Driver


Sometimes you will find a driver that is close enough to what you need that you can consider modifying one that already exists instead of starting from scratch. In this series of activities, you will modify the Scenario Experience Button to handle a range of icons so you only can install the same driver multiple times and select the icon that you will display, rather than having to make multiple drivers that functionally do the same thing.

### Music Styles Experience Button Driver
1.	Examine the Scenario Experience Driver
    a.	Open up the Scenario Experience Driver and determine how the different icons for state are being displayed.

    ```xml
    <state id="Selected">
        <Icon width="70" height="70">controller://driver/experience-button-scenario/icons/device/selected_70.png</Icon>
        <Icon width="90" height="90">controller://driver/experience-button-scenario/icons/device/selected_90.png</Icon>
        <Icon width="300" height="300">controller://driver/experience-button-scenario/icons/device/selected_300.png</Icon>
        <Icon width="512" height="512">controller://driver/experience-button-scenario/icons/device/selected_512.png</Icon>
        <Icon width="1024" height="1024">controller://driver/experience-button-scenario/icons/device/selected_1024.png</Icon>
    </state>
    ```
    b. In the `lua` code a proxy notification is handling how the icons are changed: 
    ```lua
    C4:SendToProxy(5001, "ICON_CHANGED", {icon = 'Selected', icon_description = on})
    ```

    This means that the `id` attribute of the `state` element in the xml defines the set of icons for a particular state and the proxy notification of `ICON_CHANGED` triggers a change of the icons to a new set, so long as the `id` attribute matches. This means that we can add more than one set of icons and then modify the code to account for the multiple sets.


2.	Create a `c4zproj` File
    Using an existing driver means that you won't have a c4zproj file to start. You can easily make one yourself. Be sure to include other files or folders that need to be included in the driver.

    1.	Create a c4zproj file named `music_styles.c4zproj` for the Music Styles Experience Button Driver. 

    ```xml
    <Driver type="c4z" name="music-styles-experience-button" squishLua="false">
        <Items>
            <Item type="dir" name="www" recurse="true"/>

            <Item type="file" name="driver.xml" c4zDir = ""/>
            <Item type="file" name="driver.lua" c4zDir = ""/>
        </Items>
    </Driver>
    ```

3. Modify Key Elements and Attributes
    Modify the following element values and attributes: 
    * `<name>`
    * `<creator>`
    * `<created>`
    * `<modified>`
    * `<version>`
    * `name` attribute of the `<proxy>` element

4.	Add a Property
    a. Add a property to the Music Styles Experience Button Driver
    ```xml
    <property>
        <name>Decade</name>
        <type>LIST</type>
        <items>
            <item>30s</item>
            <item>40s</item>
            <item>50s</item>
            <item>60s</item>
            <item>70s</item>
            <item>80s</item>
            <item>90s</item>
            <item>00s</item>
        </items>
        <default>30s</default>
        <readonly>false</readonly>
    </property>
    ```
5. Modify the paths of the existing states.



6.	Add Additional States and Modify the Path
    Modify the path in the default icon points to the new paths. Then add the additional states and their accompanying images
    ```xml
    <state id="Default">
        <Icon width="70" height="70">controller://driver/music-styles-experience-button/icons/30s/default_70.png</Icon>
        <Icon width="90" height="90">controller://driver/music-styles-experience-button/icons/30s/default_90.png</Icon>
        <Icon width="300" height="300">controller://driver/music-styles-experience-button/icons/30s/default_300.png</Icon>
        <Icon width="512" height="512">controller://driver/music-styles-experience-button/icons/30s/default_512.png</Icon>
        <Icon width="1024" height="1024">controller://driver/music-styles-experience-button/icons/30s/default_1024.png</Icon>
    </state>
    <state id="Selected">
        <Icon width="70" height="70">controller://driver/music-styles-experience-button/icons/30s/selected_70.png</Icon>
        <Icon width="90" height="90">controller://driver/music-styles-experience-button/icons/30s/selected_90.png</Icon>
        <Icon width="300" height="300">controller://driver/music-styles-experience-button/icons/30s/selected_300.png</Icon>
        <Icon width="512" height="512">controller://driver/music-styles-experience-button/icons/30s/selected_512.png</Icon>
        <Icon width="1024" height="1024">controller://driver/music-styles-experience-button/icons/30s/selected_1024.png</Icon>
    </state>
    <state id="Default30s">
        <Icon width="70" height="70">controller://driver/music-styles-experience-button/icons/30s/default_70.png</Icon>
        <Icon width="90" height="90">controller://driver/music-styles-experience-button/icons/30s/default_90.png</Icon>
        <Icon width="300" height="300">controller://driver/music-styles-experience-button/icons/30s/default_300.png</Icon>
        <Icon width="512" height="512">controller://driver/music-styles-experience-button/icons/30s/default_512.png</Icon>
        <Icon width="1024" height="1024">controller://driver/music-styles-experience-button/icons/30s/default_1024.png</Icon>
    </state>
    <state id="Selected30s">
        <Icon width="70" height="70">controller://driver/music-styles-experience-button/icons/30s/selected_70.png</Icon>
        <Icon width="90" height="90">controller://driver/music-styles-experience-button/icons/30s/selected_90.png</Icon>
        <Icon width="300" height="300">controller://driver/music-styles-experience-button/icons/30s/selected_300.png</Icon>
        <Icon width="512" height="512">controller://driver/music-styles-experience-button/icons/30s/selected_512.png</Icon>
        <Icon width="1024" height="1024">controller://driver/music-styles-experience-button/icons/30s/selected_1024.png</Icon>
    </state>

    ```
    Obviously there are more decades, but you get the point. You can add all of them from 1940s to 2000s.

7. Modify the `lua` Code
    Modify the code to switch to the right state.
    1. Add `DECADE_NAME` as a variable with a default value of `ancient` in the the `do … end` block of global variables.

    ```lua
    DECADE_NAME = '30s'
    ```

    2. Add this line to the OnDriverInit function: 

    ```lua
    local strDecade = Properties['Decade'] or DECADE_NAME
    ```

    3. Create a function for the Decades property changing: 

    ```lua
    function ON_PROPERTY_CHANGED.Decade (value)
        DECADE_NAME = value
        local initializing = true
        DisplayState (STATE, initializing)
    end
    ```

    4. Modify the two `ICON_CHANGED` proxy notifications to include the `DECADE_NAME`:
    ```lua
    C4:SendToProxy(5001, "ICON_CHANGED", {icon = 'Selected' .. DECADE_NAME, icon_description = on})
    ```

    ```lua
    C4:SendToProxy(5001, "ICON_CHANGED", {icon = 'Selected' .. DECADE_NAME, icon_description = off})
    ```
8. Clean Up and Make Documentation
    