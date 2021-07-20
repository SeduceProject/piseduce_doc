---
layout: post
title: Prepare your PoE Switch
subtitle: SNMP and PoE configuration
category: Administration
index: 2
---

The main hardware requires to set up a PiSeduce cluster is a PoE switch and a few Raspberry Pis. A
more precise list of the hardware can be found in this
[article](/2020-05-28-picluster-setup-from-scratch-ep1). The PoE switch is an important component of
PiSeduce clusters because it supplies the electrical energy of the Raspberrys and allows one of the
Raspberrys, called the pimaster, to turn off and on the other Raspberrys called the pislaves. To
control the PoE ports, the pimaster needs to have SNMP read/write access to the switch.

### SNMP configuration
Altough the interface of every switch is different, the SNMP configuration is usually easy and the
steps to configure the SNMP access are similar from switch to switch. In this example, we describe how
to configure the SNMP access on the D-Link switch *DGS-1210-28P*:
* Enable SNMP (SNMP > System > SNMP Global State: Enabled)
* Add a Read/Write SNMP community (SNMP > System > SNMP Community: pi-mgnt (ReadWrite)).

### SNMP Configuration Test (from Raspbian OS)
To test the SNMP configuration, we need OIDs. OIDs are pathes to SNMP information. They are
described in the MiB provided by the switch manufacturer. MiBs can be difficult to find. For the D-Link
switches, the OID used to know the state of the PoE ports starts with `1.3.6.1.2.1.105.1.1.1.3`. We
can get the state of the ports with the following commands (the switch IP is 192.0.0.3):
```
apt install snmp
snmpwalk -v2c -c pi-mgnt 192.0.0.3 1.3.6.1.2.1.105.1.1.1.3
```
The answer shows the state of all PoE ports (1: on, 2: off). To turn on one specific port, add `.1.`
followed by the port number at the end of the previous OID. For example, the following command turns
on the port 16:
```
snmpset -v2c -c private 192.168.1.23 1.3.6.1.2.1.105.1.1.1.3.1.16 i 1
snmpget -v2c -c private 192.168.1.23 1.3.6.1.2.1.105.1.1.1.3.1.16
```

### PoE configuration
From the switch interface, you can turn on and off the PoE. On our D-Link switch, the PoE port
settings are available from the menu *PoE > PoE Port Settings*. The state of every port can be set
to *enabled* or *disabled*. As only the pimaster has to be on, we disable all ports except the port
number 8. Consequently, by default or after a reboot, only the Raspberry on the port 8 will be
powered on.

### Save the configuration
Now, we are ready to save the current configuration into the startup configuration. If the current
configuration is not saved, all modifications will be lost if the switch is turned off. To save the
current configuration of our D-Link switch, we go to *Save > Save Configuration* and click on *Save
Config*.
