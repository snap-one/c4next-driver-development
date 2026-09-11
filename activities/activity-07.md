## View and Compile the Sample Light Driver

### View the `driver.xml` File

1. Look at the connections and proxy elements in the XML file. Start with the proxy XML. Note both the `proxybindingid` (which will be important in a moment) and the text content of `light_v2`. You can find more information about different proxies in the [Driverworks Proxy Documentation](https://github.com/snap-one/docs-driverworks#driverworks-proxy-documentation).

```xml
<proxy proxybindingid="5001" name="Sample Light Driver">light_v2</proxy>
```

2. Next view the connection in the XML. Note the `id` tag has the same content as the value of the `proxybindingid` attribute in the `proxy` element. The [Driverworks XML Guide](https://snap-one.github.io/docs-driverworks-xml/#connections-xml) explains what tags and text content needs to be defined in the `connection` element.

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
3. Finally, examine the capabilities. These are capabilities specific to the `light_v2` proxy. You can find their definitions and possible values in the
[Light V2 Proxy documentation](https://snap-one.github.io/docs-driverworks-proxyprotocol-lightv2/#light-v2-capabilities).

```xml
	<capabilities>
		<dimmer>True</dimmer>
		<set_level>True</set_level>
		<ramp_level>True</ramp_level>
		<on_off>True</on_off>
		<min_max>True</min_max>
		<click_rates>False</click_rates>
		<hold_rates>False</hold_rates>
		<cold_start>False</cold_start>
		<has_leds>False</has_leds>
		<supports_color_correlated_temperature>False</supports_color_correlated_temperature>
		<supports_target>True</supports_target>
		<supports_broadcast_scenes>False</supports_broadcast_scenes>
		<supports_multichannel_scenes>False</supports_multichannel_scenes>
		<hide_proxy_properties>true</hide_proxy_properties>
		<hide_proxy_events>false</hide_proxy_events>
		<reduced_als_support>False</reduced_als_support>
		<advanced_scene_support>False</advanced_scene_support>
		<load_group_support>False</load_group_support>
		<buttons_are_virtual>True</buttons_are_virtual>
	</capabilities>
```

### View the `driver.lua` File

4. View the driver.lua file and look for the `ReceivedFromProxy` function:


### Compile the driver and notice what is included with the proxy.

5. View the **Properties** tab. What do you notice can be configured just through the proxy?
6. Navigate to **Programming**. What do you notice are added automatically to events and actions.
