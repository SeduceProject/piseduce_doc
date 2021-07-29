---
layout: post
title: Offer Users New Environments
subtitle: Add Environments to the Resource Manager
category: Administration
index: 6
---

When users reserve Raspberrys from the PiSeduce resource manager, they have to choose the
environment that will be deployed on their Raspberrys. This environment contains the operating
system and, usually, additional specific packages. By default, the PiSeduce resource manager offers
only one environment: the
[Raspbian&nbsp;lite](https://www.raspberrypi.org/downloads/raspbian/){:target="_blank"} operating
system without additional package. For the most efficient use of the Raspberry cluster,
administrators can register other environments with different operating systems or additional
installed packages. See this [article](/2021-07-10-create-new-environments/) to customize an
existing operating system image. The system images are located in the environment directory defined
in the `/root/piseduce_agent/config_agent.json` file by the value of the `env_path` key.

In most cases, system images for Raspberry Pi are compressed with the `gzip` utility. As the
PiSeduce resource manager uses the `tar` utility to manage system images, administrators must
usually compress again the downloaded images. To check the system images are well compressed, use
the command `tar -tvf piCore-10.0beta12b.img.tar.gz`. The output should be the name of the file
included in the archive. To compress system images, use `tar -czf piCore-10.0beta12b.img.tar.gz
piCore-10.0beta12b.img`. The result will be a file with the `.tar.gz` extension.

**IMPORTANT**: If the resource manager manages Raspberry Pi 3, do not forget to delete the
`bootcode.bin` file of the sytem image as described in this
[article](/2021-07-10-create-new-environments#delete-the-bootcodebin-file).

The environment page allows administrators to register new images as environments. This page is
available by clicking on the *(admin) Environment* item of the menu.

[![alt Environment Page](/img/environment_page.png# bordered)](/img/environment_page.png){:target="_blank"}

To register environments, the following fields are required:
* the **img_name** property is the filename of the compressed system image. This image file must be
  located in the environment directory speficied in the `/root/piseduce_agent/config_agent.json`
  file by the `env_path` property. In the previous example, the value of this property is
  *piCore-10.0beta12b.img.tar.gz*.
* the **img_size** property is the size in bytes of the uncompressed system image. This size can be
  achieved by the command `ls -l`. In the previous example, the system image size is 88080384:
  ```
  ls -l piCore-10.0beta12b.img
  >> -rw-r--r-- 1 root root 88080384 Apr 26 18:07 piCore-10.0beta12b.img
  ```
* the **name** of the environment is the unique name that identifies the system image. This name is
  used by users to identify the environment who want to deploy on their Raspberrys and by the
  resource manager to execute specific configurations for that system image. So, the name of the
  environment is dependent of the operating system used to create it:
  * the name of environments based on Raspbian (RaspiOS) OS have to start by *raspbian*
  * the name of environments based on Ubuntu OS have to start by *ubuntu*
  * the name of environments based on piCore OS have to start by *tiny_core*  

  The environment names are used by the *agent_exec* service. Take a look at the
  `raspberry/exec.py` file.
  
  In the previous example, we choose to use the name *tiny_core_10* to identify the environment
  including the piCore system image.

* the **sector_start** is the first sector of the second partition (the system partition). This
  information is used to resize the system partition. In the previous example, the **sector_start**
  value is 139264 and it can be found the `fdisk` command:
  ```
  fdisk -u piCore-13.0.3.img
  p
  >> Disk piCore-13.0.3.img: 84 MiB, 88080384 bytes, 172032 sectors
  >> Units: sectors of 1 * 512 = 512 bytes
  >> Sector size (logical/physical): 512 bytes / 512 bytes
  >> I/O size (minimum/optimal): 512 bytes / 512 bytes
  >> Disklabel type: dos
  >> Disk identifier: 0xe85b7916
  >> 
  >> Device             Boot  Start    End Sectors Size Id Type
  >> piCore-13.0.3.img1        8192 139263  131072  64M  c W95 FAT32 (LBA)
  >> piCore-13.0.3.img2      139264 172031   32768  16M 83 Linux
  ```
* the **ssh_user** is the user that the resource manager used for the SSH connections. For Ubuntu OS
  and raspbian OS, this user is *root*. For piCore (tiny_core) OS, the user is *tc*.
* the **web** property have to be *true* if the operating system embeds a web interface as Cloud9,
  *false* otherwise. A link to the web interface will be displayed in the manage page.

After clicking on the *Add* button, the environment appears in the *Existing Environments*
section. To make the environment available for users, we need to restart the agent services:
```
service agent_api restart
service agent_exec restart
```
