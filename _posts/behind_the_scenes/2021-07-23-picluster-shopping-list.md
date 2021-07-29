---
layout: post
title: Hardware Shopping List to Make a PiCluster
subtitle: Switch, Raspberry and other stuffs
category: Behind the Scenes
index: 1
---
The goal of the PiSeduce project is to provide an academic infrastructure for Internet of Things
(IoT) developments and experiments. As such an infrastructure needs many clusters distributed over a
large geographical area, we want to encourage partners to build their own PiSeduce cluster as
cheaply as possible. By "cheaply", we mean 1) with hardware available at reasonable costs that has
been tested and 2) with as little wasted time as possible thanks to an existing software stack which
is documented. At the present time, the cost for a PiSeduce cluster is about a thousand euros for
the hardware and one day to set up the cluster (connecting the cables and installing the PiSeduce
Manager). In this article, we talk about the hardware selection.

The first device to buy is the PoE switch. The PoE (Power over Ethernet) technology allows to
provide electric power to the Raspberry Pis. One Raspberry Pi&nbsp;4 consumes about 7&nbsp;W. So, a
8-port switch must be able to provide 8&nbsp;x&nbsp;7&nbsp;=&nbsp;56&nbsp;W. The switch **PoE Power
Budget** is the total amount of power output available to the PoE ports of the switch. To choose the
switch, make sure that the total power required by all PoE devices, i.e., all Raspberry Pis, does
not exceed the PoE power budget. Also verify that every port of the switch supports the PoE
technology. For example, a 12-port switch can only have 8 PoE ports. Moreover, the switch must be
manageable with the SNMP protocol, more specifically, we need to turn off and on the PoE ports.
Nowadays, most of the switchs support this feature.  
We bought the **8-port switch** *Linksys LGS308MP* - **200 euros**.

Obviously, the other key device of the PiSeduce cluster is the Raspberry Pi. We distinguish two
types of Raspberry Pi: the pimaster and the pislaves. The pimaster hosts the PiSeduce resource
manager. It communicates with the switch and manages the other Raspberry Pis by providing them with
IP addresses, operating system images and NFS file systems.  
**For the pimaster**, we recommand to buy a Raspberry Pi 4 with 4GB of memory. Indeed, the pimaster
needs more memory and a more efficient processor than the other Raspberry Pis which we call the
pislaves. Moreover, the  Raspberry Pi 4 has Gigabyte Ethernet that improves the download of
operating system images from the pislaves and USB&nbsp;3.0 ports that can be usefull to store system
images on an external disk. At first, we installed the PiSeduce resource manager on a Raspberry Pi
3B+ but it became laggy when the activity was increasing.  
**For the pislaves**, we need Raspberry Pis that support network boot. From this
[article](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/net.md){:target="_blank"},
only the Raspberry Pi 3B, 3B+ and 2B&nbsp;v1.2 support it. The latest Raspberry, Pi 4B, also
supports the network boot. In our past experiments, we successfully build PiSeduce clusters with
both Raspberry Pi 4B and Raspberry Pi 3B+.  
In order to use the switch PoE ports as power source for the Raspberry Pis, we need to add [PoE
boards](https://www.raspberrypi.org/products/poe-hat/){:target="_blank"}, also called PoE HAT, on
every Raspberry. This PoE HAT is only compatible with Raspberry Pi 3B+ and Raspberry Pi 4B. We never
try to use it with older Raspberrys.  
For our latest cluster, we bought eight **Raspberry Pi 4B** with eight **PoE boards** - **70 euros
each (Raspberry + PoE board)**.

One of the components that could affect the performance of the cluster is poor quality SDCARDs.
There are many different models of SDCARDs with different quality as shown in the graph below (see
the full [SDCARD
benchmarks](https://www.jeffgeerling.com/blog/2019/raspberry-pi-microsd-card-performance-comparison-2019){:target="_blank"}).


![alt pimaster configuration interface](/img/pi-4-microsd-card-benchmarks-all.png# bordered)

For PiSeduce clusters, we encourage the purchase of SDCARDs with high write rates in order to reduce
the time to deploy new operating systems which is a common operation.  
We choose the *Samsung 32Gb EVO Plus* **Micro SD Card** - **14 euros each**.

To complete this shopping list, we need at least eight 1-meter **ethernet cables** (**12 euros**).
For our cluster, we also add one **USB&nbsp;3.0 drive** with a capcity of 256&nbsp;GB (**40 euros**)
for storing operating system images and one **D-Link USB&nbsp;3.0 Gigabit Ethernet Adapter (ref:
DUB-1312)** (**35 euros**) to configure the pimaster as a gateway between the cluster and another
network. Now, we are ready to connect all the devices and configure the software stack.

We hope that we have addressed all the concerns about the hardware configuration of PiSeduce clusters.
The total cost for our cluster is about **a thousand euros**.

**Pro Tips**: To organize our Raspberrys in a beautiful tower, we buy 40 Male/Female Threaded
Standoffs (M3 x M3). We choose to use the 16mm long (hexagonal body + threaded head) standoffs. We
build towers of 8 Raspberrys using 4 standoffs per Raspberry (2 for the board and 2 for the PoE HAT)
and four more standoffs to build the small legs of the tower.

![alt Raspberry Tower](/img/raspberry_tower.png# bordered)