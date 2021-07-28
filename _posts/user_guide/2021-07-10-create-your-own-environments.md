---
layout: post
title: Create your Own Environments
subtitle: Customize Operating System Images
category: User Guide
index: 3
---

For users with specifc needs, the available environments could not be appropriate. The deployment of customized
environments could also save time to you and other users. In this article, we describe two ways to create customized
environment images.
The [first way](https://doc.seduce.fr/2021-07-01-create-your-own-environments/#fast-environment-customization) is the
easiest and fastest one but all customizations are not possible.
The [second way](https://doc.seduce.fr/2021-07-01-create-your-own-environments/#full-environment-customization) allows
user to fully customize their environment. 

## Fast Environment Customization

The fastest way to create customized environments is to download the image of the operating system to modify on a
Raspberry and alter this image by adding packages. In this example, we will modify the Raspbian&nbsp;Lite operating
system to install a web terminal [ttyd](https://github.com/tsl0922/ttyd){:target="_blank"} available on the port 8080 of
the node.

### Download the Raspbian image
```
wget https://downloads.raspberrypi.org/raspbian_lite_latest -O raspbian-lite.img.gz
gunzip raspbian-lite.img.gz
```
After decompressing the archive, we get the file *raspbian-lite.img*.

### Increase the size of the Raspbian image
In this example, we increase the size of the image by 1&nbsp;GB. Take care of increasing as little as possible the image
size because the deployment time is heavily dependent on this size.
```
dd if=/dev/zero bs=1M count=1024 >> raspbian-lite.img
```

### Information about the second partition
Note the value of the fist sector of the second partition.
```
fdisk -u raspbian-lite.img
p
Disk raspbian-lite.img: 1.8 GiB, 1874853888 bytes, 3661824 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x9730496b
Device             Boot  Start     End Sectors  Size Id Type
raspbian-lite.img1        8192  532479  524288  256M  c W95 FAT32 (LBA)
raspbian-lite.img2      532480 3661823 3129344  1.5G 83 Linux
```
The first sector of the second partition is 532480.

### Expand the second partition
Delete the second partition, then, create a partition with the whole space.
```
fdisk -u raspbian-lite.img
d
(partition number) 2
n
(partition type) p
(partition number) 2
(first sector) 532480
(last sector) enter (use the default value)
(remove the signature) n
w
```

### Mount the partition
Use the loop device given by the first command (`losetup -f`), it is a free loop device.
```
losetup -f
/dev/loop1
losetup -P /dev/loop1 raspbian-lite.img
mkdir mount_dir
mount /dev/loop1p2 mount_dir/
```

### Resize the partition
```
resize2fs /dev/loop1p2
```
Now, the partition mounted on the `mount_dir` directory is 1&nbsp;GB bigger. We are ready to add our stuffs.

### Delete the bootcode.bin file
The interesting feature of the Raspberry Pi 3 is the network boot is enabled by default. Indeed, if the Pi&nbsp;3 does
not find the `bootcode.bin` file at the boot time, it initiates the PXE boot sequence. So, one way to ensure the
Raspberry always starts the network boot sequence is to remove the `bootcode.bin` file from the boot partition.
This file belongs to the first partition of system images, also called, the boot partition.
```
mkdir boot_dir
mount /dev/loop1p1 boot_dir/
rm boot_dir/bootcode.bin
umount boot_dir
```

### Copy files to the Raspbian image
The image file system is available in the `mount_dir` directory. We clone the git repository of the ttyd project in the
root account.
```
cd mount_dir/root
git clone https://github.com/tsl0922/ttyd
```
After copying files to the disk image, you will need to mount the Raspbian image from a Raspberry Pi device.

### Make changes on the Raspbian operating system
In our case, we need to install compilation tools and start the ttyd daemon at the startup.  
**WARNING**: For this section, you must mount the disk image on a raspbian operating system.
```
# chroot to the Raspbian system
cd mount_dir
mount --bind /proc proc
mount --bind /sys sys
mount --bind /dev dev
chroot .
# Update the system and install additional packages
apt update && apt -y dist-upgrade
apt install build-essential cmake git libjson-c-dev libwebsockets-dev
# Build ttyd
cd /root/ttyd && mkdir build && cd build
cmake ..
make
cp ttyd /usr/bin/
```
### Start ttyd at the start up
To run the ttyd daemon at the startup, edit the `/etc/rc.local` file and append the following line:
```
ttyd --credential myuser:mypassword -p 8080 bash -x &> /dev/null &
```
Make sure to run the program as a background task to ensure the startup process does not stuck on the command.

### Exit the system
We have finished making changes of the Raspbian image.
```
# exit the chroot
exit
umount mount_dir
losetup -d /dev/loop1
```
### Compress the environment image
Do not forget to compress the new system image with the `tar` utility and the gzip compression option `-z` before
sending it to the resource manager. 
```
tar -czf raspbian_ttyd_2021_07_09.tar.gz raspbian-lite.img
```
Now, you can contact the administrator of your PiSeduce infrastrucuture in order to add your image to the resource
manager.

## Full Environment Customization (Future Work)
This second approach is more difficult and needs more time. We start by deploying the dual_boot environment on a
Raspberry. This environment includes two operating systems: the raspbian lite OS and the tiny_core OS. This two
operating system occupy only the half of the SDCARD and a third empty partition exists in the space left. The first step
is to boot on the raspbian OS and customize it. The second step will be to boot on the tiny_core OS on dump the
customized raspbian OS to the third partition.

### Customizing the Raspbian OS
After deploying the dual_boot environment, users connect to the node on the Raspbian operating system. Now, users can
customize the environment as you want. Once the customization is completed, users have to modify the boot order to
reboot on the tiny_core OS.
* Change the cmdline.txt (see this
  [article](https://superuser.com/questions/1518984/how-to-boot-from-selected-partition-in-raspberry-pi-3))
* Upload the new boot files to the TFTP
* Reboot the operating system

### Create an archive of the raspbian OS
First, we mount the second partition from the tiny core OS.
```
mkdir mount_dir
mount /dev/mmcblk0p2 mount_dir
```
In order to reduce the size of the resulting image, we fill the empty space of this partition with zeros.
```
cd mount_dir/
dd if=/dev/zero of=zerofillfile bs=1M
rm zerofillfile
```
We note the end sector of the second partition.
```
fdisk -u /dev/mmcblk0
p
Device                                    Boot  Start     End Sectors  Size Id Type
/dev/mmcblk0p1          8192   532479   524288  256M  c W95 FAT32 (LBA)
/dev/mmcblk0p2        532480 11018240 10485761    5G 83 Linux
/dev/mmcblk0p3      11018251 12042249  1023999  500M 83 Linux
```
The last sector of the second partition is 11018240. Before creating an image of the customized operating system, we
edit the cmdline.txt to boot on the first partition.
```
vim /boot/cmdline.txt
dd if=/dev/mmcblk0 of=user_env_2021_07_09.img bs=512 count=$((11018240 + 5))
tar -czf user_env_2021_07_09.img.tar.gz user_env_2021_07_09.img
```
Now, you can contact the administrator of your PiSeduce infrastrucuture in order to add your image to the resource
manager.
