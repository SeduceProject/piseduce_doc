---
layout: post
title: Register new environments
subtitle: Add your customized environments to the Resource Manager
category: User Guide
index: 4
---

After creating the image of our customized environment, we have to compress it
with the gzip option:
```
tar czf piCore-13.0.3.img.tar.gz piCore-13.0.3.img
```
**WARNING**: the filename of the compressed image must be the filename of the
image followed by the extension *.tar.gz*.  
In order to deploy this environment of the Raspberrys from the PiSeduce resource
manager, we need to send the image to the piseduce agent. We can not directly
upload the image to the agent so we reserve one Raspberry managed by this agent
and we will use this Raspberry to register the new environment.

To select a Raspberry managed by the right agent, we can display the node
information by clicking on the *info* square next to the node name or we can add
a filter on the agent property. Then, we reserve one of the Raspberry Pi 4 for
one hour from the reserve panel. We could also use a Raspberry Pi 3 but the
process will be longer. We choose to deploy the *raspbian_buster_32bit*
environment on the whole partition.

Once deployement is completed, we upload our environment to the Raspberry (the
IP of the Raspberry is 25.25.0.26):
```
scp piCore-13.0.3.img.tar.gz root@25.25.0.26:
```
As we upload the image with the root user, the path of the file is
*/root/piCore-13.0.3.img.tar.gz*. Now, we open the *Environment Factory* panel
of the resource manager to fill the registration form. First, we select the
agent name and the name of the Raspberry that we use. We fill the Image File
Path with */root/piCore-13.0.3.img.tar.gz*.

The resource manager uses names to identify the operating system of the
environments. During the environment registration, the resource manager will
identify the operating system and the environment name will start with:
* *ubuntu_* for the Ubuntu based operating systems
* *raspbian_* for the Raspbian based operating systems
* *picore_* for the piCore based operating systems

So, we choose a suffix to create a unique environment name. This suffix will be
added to the operating system name. For instance, we fill the *Environment Name*
field with the string *13.0.3* in order to produce the environment name
*picore_13.0.3*. Then, we click on register. The progress of the registration
process can be followed in the *manage panel*. The registration process consists
of three steps: uncompress the image, read the information of the image and
upload the file to the environment repository of the agent.

After the registration process, we go to the *reserve panel* and deploy the new
environment to one Raspberry to test it. If the environment is successfully
deployed, we have a new environment available to all users. Otherwise, we must
notify administrators who must delete the environment.
