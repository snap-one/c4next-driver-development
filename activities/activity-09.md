## Make a Network Connection

This activity adds a TCP network connection to the Ultimate Button driver. The XML connection gives Director a network binding and port for communicating with the Ultimate Button device. The Lua network handlers are already present, so no Lua logic needs to be added in this activity.

### `driver.xml` - Add the TCP Connection
1. Add the following connection inside the `<connections>` element in the `driver.xml` file:
```xml
<connection>
    <id>6001</id>
    <facing>1</facing>
    <connectionname>Network</connectionname>
    <type>4</type>
    <consumer>True</consumer>
    <audiosource>False</audiosource>
    <videosource>False</videosource>
    <linelevel>True</linelevel>
    <classes>
        <class>
            <classname>TCP</classname>
            <ports>
                <port>
                    <number>1000</number>
                    <auto_connect>True</auto_connect>
                    <monitor_connection>True</monitor_connection>
                    <keep_connection>True</keep_connection>
                </port>
            </ports>
        </class>
    </classes>
</connection>
```

The binding ID `6001` must match `NETWORK_BINDING_ID` in `driver.lua`. The port number `1000` must match `NETWORK_PORT`. The connection settings tell Director to open and maintain the TCP connection automatically.

2. Save the file.

### `driver.lua` - Review the Network Handlers
3. Confirm that the `driver.lua` file contains the matching network constants:
```lua
NETWORK_BINDING_ID = 6001
NETWORK_PORT = 1000
```

4. Confirm that the file contains `OnConnectionStatusChanged` and `ReceivedFromNetwork`. These functions respond to connection changes and process newline-delimited messages received from the Ultimate Button device. No Lua changes are required for this activity.

5. Save the file.

### Compile the Driver
6. Use the **arrow-up** key to repeat the previous instructions to compile the driver.
7. In **Composer Pro**, click **Driver > Add or Update Driver or Agent**.
8. Choose the packaged driver in the **compiled** folder.

### Test the Driver in Composer Pro
9. Navigate to **Connections** > **Network** > **IP Network**.
10. You should see the Ultimate Button driver in the list of devices. Double click the driver to open up the **Identify** panel.
11. Enter or select the IP address of the Ultimate Button (you can see it in small print at the bottom of the button screen).
12. Close the panel and confirm that the button is identified as **Online** in the list of **Connections**.
