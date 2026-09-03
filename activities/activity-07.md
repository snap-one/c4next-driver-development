## View and Compile the Sample Light Driver

### View the driver.xml File

1. Look at the connections and proxy elements in the XML file. Start with the proxy XML. Note both the proxybindingid (which will be important in a moment) and the text content of **light_v2**.

```xml
<proxy proxybindingid="5001" name="Sample Light Driver">light_v2</proxy>
```

2. Next view the connection

```xml
<connection>
    <!-- This is where the 5001 "binding" (connection) is defined - in this case, a LIGHT_V2-->
    <id>5001</id>
    <facing>6</facing>
    <connectionname>LIGHT</connectionname>
    <type>2</type>
    <consumer>false</consumer>
    <audiosource>false</audiosource>
    <videosource>false</videosource>
    <linelevel>false</linelevel>
    <classes>
        <class>
            <!-- this classname is the matching classname for the proxy definition above-->
            <classname>LIGHT_V2</classname>
        </class>
    </classes>
</connection>
```

All of the 

2. Look at the capabilities and see where to find them in the proxy documentation.
3. Compile the driver and notice what is included with the proxy.
4. Load in the touchscreen to see how it functions.
