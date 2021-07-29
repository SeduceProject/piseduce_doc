---
layout: post
title: PiSeduce Installation - Episode 3
subtitle: Resource Manager Installation & Configuration
category: Administration
index: 4
---

After configuring the PoE switch and the Raspberrys, the next step is to install the PiSeduce
resource manager. The resource manager consists of two projects:
* the [piseduce_webui](http://github.com/remyimt/piseduce_webui){:target="_blank"} project runs the
  web interface (webUI) of the manager.
* the [piseduce_agent](http://github.com/remyimt/piseduce_agent){:target="_blank"} project runs the
  agent API service that communicates with the webUI and the agent executor that deploys
  environments on the Raspberrys to configure them.

The two projects can be hosted on the same machine or on two different machines. A Raspberry Pi 3
can be used as the resource manager but, if the number of concurrent deployments increases then the
web interface could be slowed. So, we prefer install the two projects on a Raspberry Pi 4 with 4 Go
of memory. This Raspberry is called the pimaster.

### Resource Manager Installation
To install the pimaster, the easy way is to download the PiSeduce image ([ARMHF
32bit](http://dl.seduce.fr/raspberry/piseduce/piseduce-armhf-28-juil-2021.img.tar.gz) or [ARM64
64bit](http://dl.seduce.fr/raspberry/piseduce/piseduce-arm64-29-juil-2021.img.tar.gz)) and write it
to the SDCARD of the pimaster:
```
wget http://dl.seduce.fr/raspberry/piseduce/piseduce-armhf-28-juil-2021.img.tar.gz
# Check the md5sum: 4754e8637d31c892c46cebf5a20c333c
md5sum piseduce-armhf-28-juil-2021.img.tar.gz
tar xvf piseduce-armhf-28-juil-2021.img.tar.gz
dd if=piseduce-armhf-28-juil-2021.img of=/dev/sdb bs=4M conv=fsync
```

The longest way to install the pimaster is to install the manager from a fresh raspbian operating
system by following this [article](/2021-07-26-manager-install-from-scratch).

The default network configuration of the PiSeduce cluster is to use the pimaster as a gateway
between an existing network with internet access and the private network 48.48.0.0/24 including the
Raspberrys connected to the switch. So there is two options to connect the pimaster to internet.

The first option is to add an USB Ethernet adapter and configure it. We use the *D-Link USB 3.0
Gigabit Ethernet Adapter (ref: DUB-1312)* which works properly. If we use this option, we have to
edit the `/etc/rc.local` file to change the network interface used in the NAT command:
```
iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
```
By default, the wireless network interface `wlan0` is used.

The second option is to connect the pimaster to an existing WIFI providing the internet access. This
option is described in the following of this article.

By default, the pimaster has the IP *48.48.0.254*. We connect to the pimaster by linking our
computer to the switch and setting the static IP *48.48.0.2* with a *255.255.255.0* netmask. Once
our computer is configured, we connect to the pimaster with SSH and the password *piseduceadmin*:
```
ssh -l root 48.48.0.254
```
If we can not physically connect our computer to the switch, try this [alternative
method](/2021-07-21-pimaster-wifi-connection).

We recommend to increase the size of the swap by editing the `/etc/dphys-swapfile` file:
```
# change the line 'CONF_SWAPSIZE=100' to 'CONF_SWAPSIZE=1024'
vi /etc/dphys-swapfile
```

### Resize the system partition
By default, the system partition is small in order to reduce the piseduce image size. Consequently,
we have to resize this partition. The `raspi-config` tool helps to use the whole SDCARD as the
system partition:
```
raspi-config
Advanced Options > Expand Filesytem > Ok
Finish > Yes
reboot
```

### WIFI connection
After logging in the pimaster with the root account, we will connect the pimaster to an existing
WIFI. First, we use the `raspi-config` tool to set the country of the WIFI:
```
raspi-config
Localisation Options > WLAN Country > FR
Finish
Reboot > No
```
Then, we set the SSID and the password of the WIFI in the WPA supplicant configuration by editing
the `/etc/wpa_supplicant/wpa_supplicant.conf` file and appending the following lines:
```
network={
  ssid="myWifiSSID"
  psk="myWifiPassword"
}
```
**WARNING: Do not add spaces before or after the '='**

Now, we connect to the WIFI with the command:
```
wpa_cli -i wlan0 reconfigure
```
If this command fails with the message *Failed to connect to non-global ctrl_ifname: wlan0*, try to
reboot the pimaster:
```
reboot
```
After few seconds, the pimaster should be connected to the WIFI. Note the IP address of the wlan0 interface:
```
ip a s wlan0
```
In the remainder of this article, the pimaster IP of the wlan0 interface is *192.168.77.68*.

To reach the Raspberrys in the *48.48.0.0/24* network from computers connected to the WIFI, we have
to add the following route:
```
# Ubuntu
sudo ip route add 48.48.0.0/24 via 192.168.77.68
# MacOS
sudo route add -net 48.48.0.0/24 gw 192.168.77.68
```
We check that the connection is properly configured by pinging the pimaster private IP:
```
ping 48.48.0.254
```

### Switch IP Configuration
As the pimaster sends SNMP queries to the switch, the pimaster must be capable of reaching the
switch from its IP. In this section, we propose to use the DHCP server of the pimaster to configure
the IP address of the switch. The DHCP server of the pimaster do not assign IP to unknown MAC
address. To register the MAC address of the switch in the DHCP server, we edit the
`/etc/dnsmasq.conf` file to append the following line (aa:bb:cc:ee:ff:00 is the switch MAC address):
```
dhcp-host=aa:bb:cc:ee:ff:00,8port_switch,48.48.0.252
```
Then, we restart the DHCP server:
```
service dnsmasq restart
```
The switch should get the IP *48.48.0.252* (a reboot of the switch can be needed).

### Resource Manager Configuration

#### SystemD Service Status
To connect to the web interface of the resource manager, we start by checking that both the *webui*
service and the *agent_api* service are running:
```
service webui status
service agent_api status
```
If the *webui* service is not running, try to restart it:
```
service webui restart
```
The log file of the *webui* service is located to */root/piseduce_webui/info_webui.log*.

If the *agent_api* service is not running, try to restart it:
```
service agent_api restart
```
The log file of the *agent_api* service is located to */root/piseduce_agent/info_api.log*.

Now, we are ready to configure our infrastructure from the web interface of the resource manager by
connecting to the URL [http://192.168.77.68:9000](http://192.168.77.68:9000). From the login page,
we log in with the admin account (login: *admin@piseduce.fr*, password: *piseduceadmin*).

#### Agent Registration
As there is no agent registered to the *webui*, the home page of the interface is almost blank. At
the left of the page, the menu allows to access the different pages. We click on the *(Admin) Agent*
item to display the agent page.

[![alt Resource Manager Agent Page](/img/agent_page.png# bordered)](/img/agent_page.png){:target="_blank"}

To register agents, the following fields are required:
* the **name** of the agent to identify it (e.g., *8switch-rasp*)
* the **ip** of the agent (e.g., *192.168.77.68*)
* the **port** of the agent is defined in the configuration file
  */root/piseduce_agent/config_agent.json*. The default port number is 8090.
* the **token** of the agent. This token is required to authorize the *webui* to send queries to the
  agent. This token is defined in the configuration file */root/piseduce_agent/config_agent.json* by
  the property *auth_token* (e.g., *12345678912345678912*)

Then, we click on the *Add* button. If everything is fine, the agent should appear in the *Existing
agents* section with the *connected* status.

The home page of the resource manager is the reserve page. We click on the *Reserve* item of the
left menu to come back to the home page. This page is always almost blank because the agent does not
know the switch and the Raspberrys.

#### Switch Registration
First, in order to register the switch, we go to the switch page accessible from the *(Admin)
Switch* item of the menu.

[![alt Resource Manager Switch Page](/img/switch_page.png# bordered)](/img/switch_page.png){:target="_blank"}

To register switches, the following fields are required:
* the **name** of the switch to identify it (e.g., *8switch-RPI4*)
* the **ip** of the switch (e.g., 48.48.0.252)
* the SNMP **community** to query the switch (e.g., *pi-mgnt*)
* the **master_port** is the port of the switch that is connected to the pimaster. As this port
  provides the power supply to the pimaster, it can not be turned off.
* the **oid_first_port** is the SNMP OID of the PoE port number one. The OIDs are described in the
  MiB provided by the switch manufacturer. More details about OID can be found in this
  [article](/2021-07-19-prepare-the-switch/).

If we do not know the OID of the first PoE port, we can try the following `snmpwalk` command (with
192.0.0.3 as the switch IP):
```
snmpwalk -v2c -c pi-mgnt 192.0.0.3 1.3.6.1.2.1.105.1.1.1.3
```
If the number of OIDs in the answer is equal to the number of ports and the value of every OID is 1
or 2, the OID of the first PoE port is the first OID of the answer. For example, the answer of the
previous command with a Linksys LGS308P switch is:
```
iso.3.6.1.2.1.105.1.1.1.3.1.49 = INTEGER: 1
iso.3.6.1.2.1.105.1.1.1.3.1.50 = INTEGER: 2
iso.3.6.1.2.1.105.1.1.1.3.1.51 = INTEGER: 2
iso.3.6.1.2.1.105.1.1.1.3.1.52 = INTEGER: 2
iso.3.6.1.2.1.105.1.1.1.3.1.53 = INTEGER: 2
iso.3.6.1.2.1.105.1.1.1.3.1.54 = INTEGER: 2
iso.3.6.1.2.1.105.1.1.1.3.1.55 = INTEGER: 2
iso.3.6.1.2.1.105.1.1.1.3.1.56 = INTEGER: 1
```
So, the **oid_first_port** value is *iso.3.6.1.2.1.105.1.1.1.3.1.49* or *1.3.6.1.2.1.105.1.1.1.3.1.49*.

Here, a list of the OID of the first PoE port that we already know:

| Switch Manufacturer   | OID of the first PoE port       |
| --------------------- | ------------------------------- |
| D-Link                | 1.3.6.1.2.1.105.1.1.1.3.1.1     |
| Linksys               | 1.3.6.1.2.1.105.1.1.1.3.1.49    |
| --------------------- | ------------------------------- |

After clicking the *Add* button, the switch appears in the *Existing switchs* section. The number of
ports of the switch should be equal to the value of the *Port_nb* property. If the number of
detected ports is wrong, the OID of first port is probably wrong too. Delete the switch and try to
fix the issue by modifying the *oid_first_port* value.

The **first_ip** column of the *Existing Switch* table defines the last digit of the IP address of
the Raspberry connected to the first port of the switch. For example, if the *first_ip* property is
equal to 9, the Raspberry on the first port of the switch will be 48.48.0.9. The Raspberry on the
second port will be 48.48.0.10, etc.

The *Switch Management* section of the switch page allows administrators to manage the PoE ports of
the selected switch. The available operations are:
* *Turn On Ports*: Turn on the selected PoE ports and, so, power on the Raspberrys on these ports.
* *Turn Off Ports*: Turn off the selected PoE ports and, so, power off the Raspberrys on these ports.
* *Port Status*: Get the PoE status for all ports. This operation takes several seconds. The ports
  in green are on and the ports in red are off.
* *Detect Nodes*: Try to detect and configure the Raspberrys on the selected ports. If the operation
  succeeds, the detected Raspberrys are added to the resource manager.

#### Raspberry Registration
The registration of Raspberrys is the final step to add them to the resource manager. This
registration can be done manually from the node page or from the switch page (recommended).

[![alt Resource Manager Node Page](/img/node_page.png# bordered)](/img/node_page.png){:target="_blank"}

To manually registrer Raspberrys as nodes, the following fields are required:
* the **ip** of the Raspberry is provided by the DHCP server of the pimaster. If we manually
  register Raspberrys, we have to take care of properly configuring IP addresses.
* the **model** of the Raspberry is used by the agent executor to execute specific reconfigurations
  that depend of the Raspberry hardware. The supported model values are: *RPI3B+1G*, *RPI4B1G*,
  *RPI4B2G*, *RPI4B4G*, *RPI4B8G*.
* the **name** of the Raspberry is a unique identifier.
* the **port_number** is the number of the PoE port connected to the raspberry. This switch port will
  be turned off/on to manage the associated Raspberry.
* the **serial** is used during the PXE boot process. This identifier is a key property to
  successfully boot Raspberrys from the NFS server hosted in the pimaster.

Both the **model** and the **serial** values used to configure Raspberrys can be obtained from the
terminal of the Raspbian OS.

To get the **model** of the Raspberry, we need the *Revision Code*: `cat /proc/cpuinfo | grep
Revision`. Then, we refer to the last table of this
[page](https://www.raspberrypi.org/documentation/hardware/raspberrypi/revision-codes/README.md){:target="_blank"}
to know the Raspberry model. The resource manager **model** identifiers are: *RPI3B+1G*, *RPI4B1G*,
*RPI4B2G*, *RPI4B4G*, *RPI4B8G*.

To get the **serial** of the Raspberry, we use the following command: `cat /proc/cpuinfo | grep
"Serial" | awk '{print substr( $3, length($3) - 7, length($3))}'`. The **serial** is a 8 hexadecimal
digit string.

From the switch page, the operation *Detect Nodes* of the *Switch Management* section allows to
register the Raspberrys. During this process, the Raspberry will reboot many times to retrieve all
the required information. This operation should be take 2 minutes per Raspberry.

To start the detection process, tick the squares associated to the ports connected to the
Raspberrys, select the *Detect Nodes* operation and click on the *Execute* button. A text area will
open to show the log of the operation. **Do not refresh the page or execute another reconfiguration
during the *Detect Nodes* process**. At the end of the operation, the Raspberry names should be
shown in the switch table close to the port numbers. The Raspberry names are composed of the name of
the agent followed by the last digit of the IP address.

To check that the Raspberrys are available to all users, we go to the reserve page. The
configured Raspberrys should be displayed in the *Available Nodes* section as shown in the picture
below.

[![alt Resource Manager Reserve Page](/img/empty_reserve_page.png# bordered)](/img/empty_reserve_page.png){:target="_blank"}
