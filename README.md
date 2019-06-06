# network-manager-force-connect-wifi
Script that will force network manager to connect to a known wifi (connection needs to be saved with the access point's name) if wifi is disconnected, but a known AP is in range. Run periodically
Note that the wifi card name (used to get status, etc) is hardcoded to wlan0. Needs nmcli to get its data (parses the output, so it may break in the future).

If multiple known access points are within range, nmcli will return the ones with the highest signal first, so you will try to connect to those first.

Example output (when wifi is disconnected):
root@lego:/usr/local/bin# ./wlan_watchdog.pl
./wlan_watchdog.pl[1366]: Started
./wlan_watchdog.pl[1366]: Visible APs: Thomson-001, internet_wireless, Clicknet-C5B0, ODROID-Test-Network, Clicknet-A96F, Clicknet-03A9, HUAWEI-4RPD, Telekom-B612, Clicknet-7094, Atena, TP-LINK_2.4GHz_EBEBA3, RomTelecom-WEP-7F54, UPC Wi-Free
./wlan_watchdog.pl[1366]: Configured APs: internet_wireless, Thomson-001, XXXX, YYYYYYY, ZZZZZZ
./wlan_watchdog.pl[1366]: Wifi is disconnected. Trying to connect
./wlan_watchdog.pl[1366]: Trying to connect to known AP Thomson-001
./wlan_watchdog.pl[1366]: Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/21)
./wlan_watchdog.pl[1366]: Wifi successfully connected to Thomson-001
Example output (when wifi is connected):
```
root@lego:/usr/local/bin# ./wlan_watchdog.pl
./wlan_watchdog.pl[1201]: Started
./wlan_watchdog.pl[1201]: Visible APs: internet_wireless, Clicknet-C5B0, ODROID-Test-Network, Thomson-001, Clicknet-A96F, Clicknet-03A9, HUAWEI-4RPD, Telekom-B612, Clicknet-7094, Atena, TP-LINK_2.4GHz_EBEBA3, RomTelecom-WEP-7F54, UPC Wi-Free
./wlan_watchdog.pl[1201]: Configured APs: internet_wireless, Thomson-001, XXXX, YYYYYYY, ZZZZZZ
./wlan_watchdog.pl[1201]: We are connected to internet_wireless. Nothing to do
```
