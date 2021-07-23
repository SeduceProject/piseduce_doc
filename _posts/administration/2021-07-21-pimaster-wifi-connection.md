---
layout: post
title: First Install WIFI Hotspot
subtitle: Connect to the pimaster without any cable
category: Administration
index: 7
---

After copying the piseduce image on the SDCARD and boot the Raspberry, we need to connect to the
pimaster, i.e., the Raspberry hosting the resource manager, to complete its configuration as
described in this [article](/2021-07-20-manager-configuration#resource-manager-installation).

The easy way to connect to the pimaster is to plug a keyboard and a screen into the Raspberry. An
alternative way is to link a computer to the switch and set a static IP, for example, *48.48.0.2*, to
the computer. However, if we are not able to do it, a third alternative is available and explained
in this article.

This alternative consists of installing a WIFI hotspot on another Raspberry connects to the switch.
This hotspot is configured to have the static IP *48.48.0.253* assigned to its Ethernet interface,
and so, it can be a gateway to connect the *48.48.0.0/24* network.

To install the hotspot, download the [raspAP
image](http://192.168.122.22/raspberry/os-images/raspAP-10-fev-2021.img.tar.gz) and write it to a
SDCARD:
```
tar xvf raspAP-10-fev-2021.img.tar.gz
mkfs.vfat -I /dev/sdb
dd if=raspAP-10-fev-2021.img of=/dev/sdb bs=4M conv=fsync
```
Then, plug the Raspberry into the switch with an Ethernet cable. Do not forget to enable the
PoE port if this one is off!

Once the Raspberry is booted, the WIFI named *piseduce_cluster* should be available. You can connect
to this WIFI with the password *piseduceCONFIG*. To make sure the Raspberry is booting, we must see
the green LED blinking after 30 seconds. If the LED does not blink, there is something wrong with
the SDCARD. We can try to write it again.

After connecting to the *piseduce_cluster* WIFI, we have an IP in the *10.3.141.0/24* network. From
this network, we can join the pimaster by using the IP *48.48.0.254* and the password
*piseduceadmin*:
```
ssh -l root 48.48.0.254
```

So, we are connected to the PiSeduce cluster without any cable and we can proceed with the
configuration of the resource manager.