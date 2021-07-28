---
layout: post
title: PiSeduce Resource Manager Troubleshooting
subtitle: Services and Log files
category: Administration
index: 11
---

### Targeted Issues 1
The web interface is not available on the port 9000 of the pimaster.

### Troubleshooting 1
We have to connect on the pimaster to check the webui service status:
```
service webui status
```
The service must be running. If the service is running, we try to restart it:
```
service webui restart
```
If the issue persists, we take a look at the `piseduce_webui/info_webui.log` file. After restarting
the webui service, we should see the following line:
```
* Running on http://0.0.0.0:9000/ (Press CTRL+C to quit)
```
Some log messages could be printed in the system logs `/var/log/syslog`.

### Targeted Issues 2
There is no node displayed at the reserve page (home page).

### Troubleshooting 2
When the piseduce_webui fails to communicate with the piseduce_agent, this agent could be
disconnected to avoid to slow down the web interface. Ressources of disconnected agents are not
available so they do not appear in the reservation page. To reconnect the agent, we go to the Agent
page and we click on the Reconnect button.

If the agent fails to reconnect, we check the agent_api service status:
```
service agent_api status
```
If the service is not running, we try to restart it:
```
service agent_api start
```
If the issue persists, we take a look at the `piseduce_agent/info_api.log` file. After restarting
the agent_api service, we should see the following line:
```
* Running on http://0.0.0.0:8090/ (Press CTRL+C to quit)
```
The default port number is 8090 but, this port can be changed by editing the file
`config_agent.json`. Check the value of the `port_number` property. Some log messages could be
printed in the system logs `/var/log/syslog`.

### Targeted Issues 3
One of the two issues exists:
* The Raspberrys do not boot and stay in the first `turn_off` state.
* The `Detect nodes` switch operation fails **before** assigning the IP address to the Raspberry.

### Troubleshooting 3
Before booting Raspberrys, we turn off their PoE port to ensure the Raspberry is off. The turn off
operation is done by using the following SNMP command (48.48.0.252 is the switch IP):
```
# The OID depends of the switch so it can be different
snmpset -v2c -c piremy 48.48.0.252 iso.3.6.1.2.1.105.1.1.1.3.1.51 i 2
```
This issue is probably related to the switch configuration. First, we check the switch IP:
```
ping 48.48.0.252
```
In the default configuration, the DHCP server on the pimaster assigns IP to the switch. So, we check
the status of the DHCP server and we restart it if necessary:
```
service dnsmasq status
service dnsmasq restart
```
If the IP issue persists, we can try to restart the switch.

If the switch answers to the `ping` command, we check the switch community by executing a read
command:
```
# The OID depends of the switch so it can be different
snmpget -v2c -c piremy 48.48.0.252 iso.3.6.1.2.1.105.1.1.1.3.1.51
```
If the command fails, we check the switch configuration and make sure we use the good community
name. If the switch configuration has not been saved, this configuration is lost when the switch is
powered off or restarted. Make sure to save the configuration of the switch after modifying it (see
this [article](/2021-07-19-prepare-the-switch) about the switch configuration).

### Targeted Issues 4
One of the two issues exists:
* The Raspberrys do not boot. After being in the first `turn_on` or `ssh_test` state, the Raspberrys
go to the `lost` state.
* The `Detect nodes` switch operation fails **after** assigning the IP address to the Raspberry.

### Troubleshooting 4
This is probably the most common issue when the manager has been newly installed. To validate the
`turn_on` state, the manager must successfully send a `ping` command to the Raspberry. To validate
the `ssh_test` state, the manager must successfully connect with SSH to the Raspberry. In this two
cases, the `lost` can be due to the operating system that fails to boot.

The first test is to wait one minute in the `lost` state. Then, we check the network connectivity to
the Raspberry with the `ping` command, if successful, we try to connect with SSH.

The second way is to take a look at the system logs `/var/log/syslog`. The IP assignment from the
DHCP server is printed in this file:
```
DHCPREQUEST(eth0) 48.48.0.3 dc:a6:32:d7:4a:80
DHCPACK(eth0) 48.48.0.3 dc:a6:32:d7:4a:80 rasp-3
```
We must see the DHCP request and the acknowledgement that confirms the IP is assigned. If we have
the message `no address available`, we check the DHCP configuration. There is no IP assigned to the
MAC address. This full message looks like this:
```
DHCPDISCOVER(eth0) dc:a6:32:d7:4a:d1 no address available
```
We also must see the PXE boot process by reading the system logs. The trace of the boot process
looks like the following lines:
```
sent /tftpboot/2e2f16b6/config.txt to 48.48.0.3
file /tftpboot/2e2f16b6/pieeprom.sig not found
file /tftpboot/2e2f16b6/recover4.elf not found
file /tftpboot/2e2f16b6/recovery.elf not found
sent /tftpboot/2e2f16b6/start4.elf to 48.48.0.3
sent /tftpboot/2e2f16b6/fixup4.dat to 48.48.0.3
file /tftpboot/2e2f16b6/recovery.elf not found
sent /tftpboot/2e2f16b6/config.txt to 48.48.0.3
file /tftpboot/2e2f16b6/dt-blob.bin not found
Early terminate received from 48.48.0.3
failed sending /tftpboot/2e2f16b6/kernel8.img to 48.48.0.3
file /tftpboot/2e2f16b6/armstub8-32-gic.bin not found
error 0 Early terminate received from 48.48.0.3
failed sending /tftpboot/2e2f16b6/kernel7l.img to 48.48.0.3
sent /tftpboot/2e2f16b6/kernel7l.img to 48.48.0.3
```
If there is this trace but the Raspberry is not properly configure, the issue could come from the
files sent to the Raspberry. If the operating system of the Raspberry has been updated but the boot
files in the PXE server (in the `/tftpboot/raspberry_serial/`) have not been updated, for example,
the `cmdline.txt` file can be modified with the operating system updates.

If there is no trace of the PXE boot process, the network boot is probably misconfigured. We
describe the PXE network configuration of Raspberry in this
[article](/2021-07-19-prepare-raspberrys). If this issue appears with Raspberry Pi 3B+, the
following troubleshooting can fix the issue.

### Targeted Issues 5
Raspberry Pi 3B+ fails to boot or boots in the SDCARD instead of from the PXE boot.

### Troubleshooting 5
The Raspberry Pi 3B+ network boot is enabled when the `bootcode.bin` file is **not** detected on the
SDCARD. If this file exists, the Raspberry boot from the SDCARD. So, if the `bootcode.bin` file
exists in the user environment images, this file will be copied during the deployment process. So,
the node will not boot from the network anymore. The `bootcode.bin` file can also be downloaded to
the SDCARD during some system updates. In this case, the manager should delete the file during the
`destroy` process. However, if user deletes the SSH key of the manager, the manager can not access
the Raspberry, and so, the file is not deleted. In this case, we have to manually erase the
`bootcode.bin` file, for example, by formating the SDCARD:
```
mkfs.ext4 /dev/mmcblk0
```
### Targeted Issues 6
Users reserve Raspberrys and see them in the manage page but their Raspberrys stay in the `ready`
state.

### Troubleshooting 6
First, we check that the `agent_exec` service is running. We take a look at the
`piseduce_agent/info_exec.log` file to check if there are error messages. If there is no error
message, the issue may come from the date of the pimaster.

To confirm this assumption, we display the `schedule` database table:
```
cd /root/piseduce_agent/
sqlite3 test-agent.db "select * from schedule;"
>> localA-3|admin@piseduce.fr|test_pi4|1627484160|1627491360|ready|deployed
```
Then, we display the local time of the pimaster:
```
date +%s
>> 1627485300
```
If the local time of the pimaster is less the first timestamp of the deployment in the database (in
the example, *1627484160*) then the local time of the pimaster is wrong. The time of the pimaster
should be updated when the pimaster is connected to the Internet. So, check your network
connectivity or update the pimaster time manually or by using ntp servers.