---
layout: post
title: Set up your own PiSeduce cluster
subtitle: Quick Boostrap your Raspberry Pi Cluster
category: Administration
index: 42 
---

The main hardware requires to set up a PiSeduce cluster is a POE switch and at least eight Raspberry Pis. A more precise
list of the hardware can be found in this [article](/2020-05-28-picluster-setup-from-scratch-ep1). So, the first step
consists of connecting the Raspberry Pis to the switch. One of the eight Raspberry Pis will be the pimaster. The other
Raspberry will be called pislaves. We recommend to choose the Raspberry with the larger amount of memory as the
pimaster. This Raspberry will manage the other Raspberry Pis by providing operating system images via the PXE protocol
and by sending SNMP requests to the switch in order to turn off and on the other Raspberry. Consequently, the pimaster
must be able to connect to the switch with the SNMP protocol with the version 2. Only this Raspberry needs a SNMP
connection to the switch.

After connecting the Raspberrys to the switch, the SNMP configuration of the switch should be straightforward. Usually,
the SNMP configuration consists of setting the name of the SNMP community, selecting the version of the protocol to use
(in our case, we use SNMPv2) and authorizing IP addresses to connect. As the pimaster will modify values of SNMP
properties, it needs to have read and write SNMP rights.

The next step is the Raspberry Pi configuration. In PiSeduce clusters, the pimaster will install new operating systems
on the Raspberry Pis by using a network PXE boot, also called, Ethernet boot. The boot configuration of the Raspberry Pi
is heavily dependent of the Raspberry Pi model. We already test two models: the Raspberry Pi 3B+ and the Raspberry Pi
4B:
* **Network configuration of Raspberry Pi 3B+**  
  For Raspberry Pi 3B+, the boot sequence tries to load the `bootcode.bin` file. If this file is not found, the
  Raspberry will initialize the network boot sequence. So, the network configuration is done by deleting the
  `bootcode.bin` file of the boot partition (the first partition of the SDCARD) or by inserting an empty SDCARD in the
  Raspberry.
* **Network configuration of Raspberry Pi 4B**  
  For Raspberry Pi 4B, the boot sequence configuration is written in the Raspberry EEPROM and the default boot is the
  SDCARD boot. So, we have to update the EEPROM to select the network boot. This operation can be done from the Raspbian
  operating system. Follow the next steps to configure the network boot:
  * Install the Raspbian operating system on the Raspberry
  * Update the operating system: `apt update && apt -y dist-upgrade`
  * Install the EEPROM tool: `apt install rpi-eeprom`
  * Copy the EEPROM file: `cp /lib/firmware/raspberrypi/bootloader/critical/pieeprom-2020-04-16.bin pieeprom.bin`
  * Extract the EEPROM configuration: `rpi-eeprom-config pieeprom.bin > bootconf.txt`
  * Modify the boot order variable of the `bootconf.txt` to `BOOT_ORDER=0x2`
  * Generate a new EEPROM file: `rpi-eeprom-config --out netboot-pieeprom.bin --config bootconf.txt pieeprom.bin`
  * Update the EEPROM: `rpi-eeprom-update -d -f netboot-pieeprom.bin`
  * Then, start every Raspberry to configure from this SDCARD and execute the last command:
  `rpi-eeprom-update -d -f netboot-pieeprom.bin`.

Now, we are ready to configure the pimaster. In order to easily configure the pimaster, we build an image file that
embeds the software stack. Download the image [piseduce.img.tar.gz](http://pi.seduce.fr/) and copy it to a SDCARD: `dd
if=piseduce.img of=/dev/sda`. By default, the pimaster uses the static IP *192.168.0.4*. The IP configuration can be
changed from the web interface described below but this change can also be done manually. To change the IP address
before booting the pimaster, edit the file `/etc/dhcpcd.conf` in the second partition of the SDCARD. The static IP
configuration is done by the following lines:
```
interface eth0
static ip_address=192.168.0.4/24
static routers=192.168.1.10
static domain_name_servers=192.168.1.10
```
The `ip_adress` property configures the IP of the pimaster. The `routers` property configures the gateway IP and the
`domain_name_servers` property configures the domain name servers IP. To use a DHCP server, comment these four lines
by adding `#` at the beginning of the lines.

To easily connect to the pimaster, your SSH key can be added to the `/root/.ssh/authorized_keys` located on the second
partition of the SDCARD. Be carefull not to delete this file or the keys inside this file. By default, SSH root access
is only available from SSH keys. SSH access for the *pi* account uses the password *piseduceadmin*. Do not forget to
change this password.

To continue the configuration of the pimaster, connect to its web interface on
[http://pimaster.local:9000](http://pimaster.local:9000).

![alt pimaster configuration interface](/img/pimaster_configuration_interface.png# bordered)

The section **Network Configuration** allows to modify the IP configuration of the pimaster. The static IP can be
changed and a gateway can be defined to allow the pimaster to connect to the internet. Otherwise, the pimaster can use
the DHCP protocol to retrieve this network configuration. From this information, the network IP is calculated. The
network mask is always 255.255.255.0. The DHCP, running on the pimaster, will use this IP range to provide Raspberry Pi
with IP addresses. The size of the IP range depends on the number of switch ports.

The section **Switch Configuration** allows to fill the switch IP and the number of ports on the switch. Then, the
SNMP community and the SNMP OID is required. From these properties, the pimaster will turn on and off every switch ports
in order to detect the Raspberry Pis. The detected Raspberry will be added to the DHCP configuration and to the PiSeduce
resource manager. Do not forget to fill the port number of the pimaster otherwise it will turn off.

The section **Database Configuration** allows to configure passwords for both the root account and the user account. The
user account created during the installation will be called *pipi*.

After clicking on the *Save Configuration* button, the configuration of the pimaster will start. Logs will be displayed.
At the end of the configuration, you should be able to connect to the [PiSeduce resource manager
interface](http://pimaster.local:9000) with the login *admin@piseduce.fr* and the password *piseduceadmin*.

## Only Use Specific Ports of the Switch
In order to only use a part of the switch ports, you can manually select the ports connected to Raspberry Pis before
running the configuration script (i.e., before clicking on *Save Configuration*). To do that, connect to the pimaster,
for example, with the SSH access. Edit the file `/root/seduce_pp/autoconf/files/master-conf-script` and write the list
of the selected ports in the variable *PORTS*. By default, this variable is set to an empty string. For example, for a
cluster of three pislaves connected on the ports 3, 6 and 7, modify the variable to:
```
# Restrict the switch ports to use.
PORTS="3 6 7"
```

## PiSeduce Resource Manager Performance
To reduce the size of the *piseduce.img* image file, the installed system have limited free space. By default, the
system will be resized at the first boot. If the `init_resize.sh` script is not run, there is sufficient free
space to install the resource manager and test it, but, we strongly advise to expand the system partition to avoid
performance issues. To manually expand the partition, start by increasing the size of the second partition (the SDCARD
is mounted on /dev/sda):
```
fdisk -u /dev/sda
# Note the first sector of the second partition (the start column)
p
# Delete the second partition
d; 2
# Create a new second partition that uses all the available space
n; p; 2; first_sector_nb; ''
# Save the modification
w
```
Now, resize the expanded partition:
```
resize2fs /dev/sda2
```
Boot on the SDCARD and check the size of the filesystem:
```
df -h
```