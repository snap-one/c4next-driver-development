# Virtual Ultimate Button Simulator

This companion app replaces the physical ESP32 button for testing the Virtual Ultimate Button driver. It uses only the Python standard library.

## Start the simulator

Use Python 3.9 or later. From this folder, run the command for your operating system:

```powershell
py simulator.py
```

On macOS or Linux, run:

```sh
python3 simulator.py
```

Open [http://127.0.0.1:8080](http://127.0.0.1:8080) on the laptop. The page displays the button name, brightness, and colors sent by the driver. Tap or press and hold the on-screen button to send events back to the driver.

## Connect the driver

1. Find the laptop's IPv4 address on the local network.
2. In Composer Pro, set the Virtual Ultimate Button driver's **Network** connection to that address.
3. Keep the simulator running. It listens for the Control4 connection on TCP port `10000`.
4. Allow inbound TCP port `10000` through the laptop firewall if prompted. On Windows, allow Python through Windows Defender Firewall on **Private networks** so the Control4 controller can connect.

The web page listens only on the laptop (`127.0.0.1:8080`). The TCP simulator listens on the laptop's network interfaces (`0.0.0.0:10000`) so the Control4 controller can connect. Do not expose the simulator port to the public internet.

The port is fixed to keep the driver's network connection metadata and Lua code synchronized. If you change it, update all three values: `TCP_PORT` in `simulator.py`, `NETWORK_PORT` in the driver's `driver.lua`, and the TCP `<number>` in the driver's `driver.xml`.
