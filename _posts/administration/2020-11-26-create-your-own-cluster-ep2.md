---
layout: post
title: Set up your own PiSeduce cluster - Episode 2
subtitle: Describing your cluster
category: Administration
index: 41
---

After installing the management services on the pimaster, we are ready to configure the PiSeduce resource manager by
describing the cluster. This description consists of several JSON files located at the `cluster_desc` directory.
The description of the cluster ressources can be done from the *Admin* page. To manually describe the ressources, read
this [article](/2020-04-24-manager-configuration-files) that explains the syntax of the configuration files.

## Describing the switches
To display the *Admin* page, click on the yellow button *Admin* of the menu at the top of the page. We start the
description of the cluster with registering the switches that connect the nodes to the cluster. The following
information must be provided:
* *Name of the switch*: the unique identifier of the switch
* *IP address of the switch*: the IP address of the switch
* SNMP Community: the SNMP community to read and write SNMP properties. The SNMP commands are used to turn off/on the
  nodes by enabling/disabling the PoE power of the switch ports.
* *Number of ports*: The number of PoE ports of the switch. The number of ports is used to know the number of raspberry
  that can be connected to the switch.
* *PiMaster port number*: If there is a pimaster, i.e. a node that executes the PiSeduce resource manager, specify its
  switch port. The PoE power of this port will stay enabled in order to keep the node on. If all ports can be turned
  off, use the *0* value.
* *OID to turn off/on the first port*: The SNMP OID address to enable/disable the PoE power of the first port of the
  switch. The OID is a string of number separated by dots that depends on the switch manufacturer. For example, the OID
  to access the first port of our Lynksys switch is `1.3.6.1.2.1.105.1.1.1.3.1.49` and this one to the first port of
  our D-Link switch is `1.3.6.1.2.1.105.1.1.1.3.1.1`.
  To find the OID of your first port, you can try the following command:
  ```
  snmpgetnext -c *your_snmp_community* -v2c *your_switch_ip* 1.3.6.1.2.1.105.1.1.1.3.1
  > iso.3.6.1.2.1.105.1.1.1.3.1.49 = INTEGER: 1
  ```
  The OID of the answer is probably the OID to the first port of the switch. The value of this port is 1 (turn on). To
  turn off the node of this port, the command is:
  ```
  snmpset -c *your_snmp_community* -v2c *your_switch_ip* 1.3.6.1.2.1.105.1.1.1.3.1.49 2
  ```

Now, we can click on the yellow button *ADD SWITCH*.

To test the connectivity to your switch, you can use the *Update PoE Status* button. If the switch configuration is
right, the ports with enabled PoE power should be in green and this ones with disabled PoE power should be in red.
You can use the *Turn Ports On* and *Turn Ports Off* buttons to enable or disable the PoE power of the selected ports.

## Describing the nodes
The node description consits of one JSON file that belongs to the `cluster_desc/nodes` directory. This files contains
the following information about the node:
* the unique name of the node that identifys the node in the resource manager
* the port number that is used to turn off/on the node
* the IP address that is used to SSH connection to the node
* the switch that is used to send the SNMP commands
* the model that is used to identify the type of the resource
* the id that is used during the PXE boot sequence

All this information can be retrieved by analyzing the port of the switch from the *Analyze Ports* button. As we
need to boot the node multiple times to gather all the information, the node detection could be long (5 minutes per
node). We advise to test this feature on one node before starting the analyze of all ports.

**NOTE**: The port analyse uses the DHCP server. Check that the *dnsmasq* service is running on your PiSeduce resource
manager before starting the node detection.

The node detection procedure is written in the *check_port* function that belongs to `blueprints/webapp_admin.py` file.
The log messages are written to `/tmp/pifrontend.log`.

## Manage users
To authorize users to log in the PiSeduce resource manager, the administrator of the cluster must confirm their user
account. This [article](/2020-04-24-user-management) explains the user management from the *Admin* page.
We strongly advise the administrator to test the deployment of few nodes before confirming user accounts.
