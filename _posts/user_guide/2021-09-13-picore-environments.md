---
layout: post
title: Create piCore environments 
subtitle: Raspberry Pi minimalist environments
category: User Guide
index: 5
---

The piCore operating system is a part of the Core Project that produces very
small Linux operating systems. So the system image size is dramatically reduced
and the operating system is very fast to boot and use a small amount of memory.
In this article, we show how to build an piCore environment image for the
PiSeduce resource manager.

The piCore OS is a modular based system. So, we configure this system by adding
multiple modules. For using piCore OS with the resource manager, we must
configure the SSH module at least. To add modules, we have two options: install
the modules from a running piCore OS or add the module files in the piCore
images.

For the first option, we install the piCore OS on a Raspberry and connect to it
with a keyboard and a screen. Then, we install and configure modules with the
package manager by using the `tce-load` command. The available module list are
available [here](http://repo.tinycorelinux.net/12.x/x86/tcz/){:target="_blank"}.
A good tutorial to install modules as the SSH module is available
[here](https://iotbytes.wordpress.com/configure-ssh-server-on-microcore-tiny-linux/){:target="_blank"}.
After the system configuration, we copy the module archive `mydata.tgz` to the
piCore image (here, *piCore-13.0.3.img*). After configuring your Raspberry, we
can copy the module archive by following the steps described
[here](/2021-09-13-picore-environments#replace-the-module-archive-of-the-picore-1303-image).
Do not forget to [delete the bootcode.bin
file](/2021-09-13-picore-environments#delete-the-bootcodebin-file) of your
resulting environment image.

For the second option, we mount the piCore image and add directly the modules to
the system image file (here, the *piCore-13.0.3.img* file). With this option, we
can not test the module configuration before deploying the customized image on a
Raspberry. As this option is less intuitive, we describe it in the rest of this
article.

### Download the piCore OS
To build the environment image, we start by downloading the piCore OS image:
```
wget http://tinycorelinux.net/13.x/armv6/releases/RPi/piCore-13.0.3.zip
unzip piCore-13.0.3.zip
```

### Delete the bootcode.bin file
Then, we mount the first partition of the image to the local directory
*mount_dir*:
```
losetup -f
>> /dev/loop20
losetup -P loop20 piCore-13.0.3.img
mkdir mount_dir
mount /dev/loop20p1 mount_dir/
```
We remove the *bootcode.bin* file to ensure Raspberry Pi 3 execute the PXE boot
sequence:
```
rm mount_dir/bootcode.bin
umount mount_dir
```

### Extract the module archive
Now, we mount the second partition of the piCore image in order to customize the
module archive.
```
mount /dev/loop20p2 mount_dir/
mkdir data_dir
cp mount_dir/tce/mydata.tgz data_dir/
tar xvf mydata.tgz
```

### Customize the module configuration
We must check the SSH module exists in the configuration. (In a running
operating system, the module directory is located at
`/mnt/mmcblk0p2/tce/optional/`.) The existing modules are located at the
`tce/optional` directory:
```
ls mount_dir/tce/optional
>> ca-certificates.tcz          openssh.tcz      openssh.tcz.md5.txt  openssl.tcz.dep
>> ca-certificates.tcz.md5.txt  openssh.tcz.dep  openssl.tcz          openssl.tcz.md5.txt
```
If the `openssh.tcz` file does not exist, we can download it from the [tinycore
repository](http://repo.tinycorelinux.net/12.x/x86/tcz/){:target="_blank"}:
```
cd mount_dir/tce/optional
wget http://repo.tinycorelinux.net/12.x/x86/tcz/openssh.tcz
cd ../../..
```
To load this module at startup, we edit the file `mount_dir/tce/onboot.lst` and
add the following line:
```
openssh.tcz
```
In the `data_dir` directory, we must see the home directory of the *tc* user:
```
ls -al data_dir/home/tc/
```
It contains multiple hidden files (files starting by '.'). If the directory does
not exist, we can create it. Then, we add the SSH public key of the resource
manager:
```
mkdir data_dir/home/tc/.ssh
scp root@manager_ip:/root/.ssh/id_rsa.pub data_dir/home/tc/.ssh/authorized_keys
```
Now, we can create a new module archive by compressing the `data_dir`:
```
cd data_dir
tar czf mydata.tgz *
```

### Replace the module archive of the piCore-13.0.3 image
We replace the existing module archive:
```
# If the partition is not mount, uncomment the following line
#mount /dev/loop20p2 mount_dir/
cp data_dir/mydata.tgz mount_dir/tce/mydata.tgz
```

### Register the new piCore image to the resource manager
We compress the new piCore image:
```
umount mount_dir
losetup -d /dev/loop20
tar czf piCore-13.0.3.img.tar.gz piCore-13.0.3.img
```
For testing the environment image, we have to register the
`piCore-13.0.3.img.tar.gz` file as a PiSeduce environment of resource manager.
The environment registration is described in this
[article](/2021-09-01-register-environments).
