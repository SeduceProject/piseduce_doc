---
layout: post
title: Create New Environments
subtitle: Customize Operating System Images
category: User Guide
index: 3
---

For users with specifc needs, the available environments could not be
appropriate. So, the deployment of customized environments could save time and
help users to run their experiments. In this article, we describe two ways to
create customized environment images. The [first
way](/2021-07-10-create-new-environments/#fast-environment-customization) is the
easiest and fastest one but all customizations are not possible. The [second
way](/2021-07-10-create-new-environments/#full-environment-customization-future-work)
allows user to fully customize their environment.

## Fast Environment Customization

The fastest way to create customized environments is to download the image of
the operating system to modify on a Raspberry and alter this image by adding
packages. In this example, we will modify the Raspbian&nbsp;Lite operating
system to install a web terminal
[ttyd](https://github.com/tsl0922/ttyd){:target="_blank"} available on the port
8080 of the node.

### Download the Raspbian image
```
wget https://downloads.raspberrypi.org/raspbian_lite_latest -O raspbian-lite.img.gz
gunzip raspbian-lite.img.gz
```
After decompressing the archive, we get the file *raspbian-lite.img*.

### Increase the size of the Raspbian image
In this example, we increase the size of the image by 1&nbsp;GB. Take care of
increasing as little as possible the image size because the deployment time is
heavily dependent on this size.
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
Use the loop device given by the first command (`losetup -f`), it is a free loop
device.
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
Now, the partition mounted on the `mount_dir` directory is 1&nbsp;GB bigger. We
are ready to add our stuffs.

### Delete the bootcode.bin file
The interesting feature of the Raspberry Pi 3 is the network boot is enabled by
default. Indeed, if the Pi&nbsp;3 does not find the `bootcode.bin` file at the
boot time, it initiates the PXE boot sequence. So, one way to ensure the
Raspberry always starts the network boot sequence is to remove the
`bootcode.bin` file from the boot partition. This file belongs to the first
partition of system images, also called, the boot partition.
```
mkdir boot_dir
mount /dev/loop1p1 boot_dir/
rm boot_dir/bootcode.bin
umount boot_dir
```

### Copy files to the Raspbian image
The image file system is available in the `mount_dir` directory. We clone the
git repository of the ttyd project into the root account.
```
cd mount_dir/root
git clone https://github.com/tsl0922/ttyd
```
After copying files to the disk image, we will need to mount the Raspbian image
from a Raspberry Pi device.

### Make changes on the Raspbian operating system
In our case, we need to install compilation tools and start the ttyd daemon at
the startup.  
**WARNING**: For this section, we must mount the disk image on a raspbian operating system.
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
To run the ttyd daemon at the startup, edit the `/etc/rc.local` file and append
the following line:
```
ttyd --credential myuser:mypassword -p 8080 bash -x &> /dev/null &
```
Make sure to run the program as a background task to ensure the startup process
does not stuck on the command.

### Exit the system
We have finished making changes of the Raspbian image.
```
# exit the chroot
exit
umount mount_dir
losetup -d /dev/loop1
```
### Compress the environment image
Do not forget to compress the new system image with the `tar` utility and the
gzip compression option `-z` before uploading it to the resource manager:
```
tar -czf raspbian_ttyd_2021_07_09.tar.gz raspbian-lite.img
```
Now, we need the administrator rights to configure the PiSeduce resource manager
in order to make our new image available to all users.

## Full Environment Customization
This second approach is more difficult and needs more time. We start by
deploying the operating system (OS) to customize on a Raspberry. This OS is
deployed on a small partition of the SDCARD. The partition size must be large
enough to customize it. However, we want to use a partition as small as possible
to reduce the size of the resulted environment image. Then, we customize the
operating system, e.g., by adding packages. After the customization, we install
the tiny core OS on the remaining part of the partition. To create the
environment image, we boot the tiny core OS and copy the customized OS to an
image file on the SDCARD.

The following paragraphs described, step by step, the customization of the
raspbian OS.

### Customizing the Raspbian OS
First, we use the PiSeduce resource manager to deploy the raspbian_buster_32bit
environment on a Raspberry Pi 4. From the *configure* panel, we modify the value
of the part_size field to *5gb* in order to install the operating system on a
5&nbsp;GB partition. Then, we click on the *Deploy* button.

After the deployment, we use SSH to access the system. We update the OS and
install packages.
```
apt update
apt -y dist-upgrade
apt install vim sqlite3
```

### TinyCore OS installation
To install the tinyCore OS, we create a new partition from the free space of the
partition. To find the first sector of this partition, we display the existing
partition with the `fdisk` command and we add 10 sectors to the last sector of
the second partition (the last partition):
```
fdisk -l /dev/mmcblk0

>> Disk /dev/mmcblk0: 29.8 GiB, 32010928128 bytes, 62521344 sectors
>> Units: sectors of 1 * 512 = 512 bytes
>> Sector size (logical/physical): 512 bytes / 512 bytes
>> I/O size (minimum/optimal): 512 bytes / 512 bytes
>> Disklabel type: dos
>> Disk identifier: 0x907af7d0
>> 
>> Device         Boot  Start      End  Sectors  Size Id Type
>> /dev/mmcblk0p1        8192   532479   524288  256M  c W95 FAT32 (LBA)
>> /dev/mmcblk0p2      532480 11018240 10485761    5G 83 Linux
```
In our installation, the last sector of the second partition is 11018240. So,
the first sector of the new partition will be 11018250 (11018240 + 10). Now, we
create the new partition:
```
fdisk /dev/mmcblk0
n
p
3
11018250
[enter] (use the default value)
w
```
We download the [tinyCore
OS](http://dl.seduce.fr/raspberry/piseduce/piCore-11.0.img.tar.gz) and we copy
it to the new partition with the `rsync` tool:
```
# Format the new partition
mkfs.ext4 /dev/mmcblk0p3
# Download tinyCore OS
wget http://dl.seduce.fr/raspberry/piseduce/piCore-11.0.img.tar.gz
tar xf piCore-11.0.img.tar.gz
# Mount the new partition
losetup -P loop0 piCore-11.0.img
mkdir new_part picore_fs
mount /dev/loop0p2 picore_fs
mount /dev/mmcblk0p3 new_part
rsync -a picore_fs/ new_part/
```

### Boot on the tinyCore OS
To boot the tinyCore OS, we have to modify the boot files of the TFTP server of
the PiSeduce resource manager. So, we install the tinyCore boot files to the
`/boot` directory before using the `Upload boot files` reconfiguration of the
*manage* panel to configure the TFTP server. In order to boot from the third
partition, we have to add the boot option `tce=mmcblk0p3/tce/` to the
`cmdline3.txt` file: 
```
mount /dev/loop0p1 /boot
# Append 'tce=mmcblk0p3/tce/' to the cmdline3.txt file
vim /boot/cmdline3.txt
```
Now, we select our Raspberry and run the `Upload boot files` reconfiguration of
the *Node Reconfiguration* section. We are ready to reboot our Raspberry:
```
reboot
```
The first start of the tinyCore OS is long (about 5 minutes on a Raspberry Pi
4). We usually can ping the Raspberry after 40 seconds. After the boot, we
connect with SSH to the Raspberry by using the user **tc** and the password
**piCore**.

### Create an archive of the raspbian OS (the customized OS)
In order to reduce the size of the resulting image, we fill the empty space of
the operating system partition with zeros.
```
cd /mnt/mmcblk0p2
sudo dd if=/dev/zero of=zerofillfile bs=1M
sudo rm zerofillfile
```
We note the end sector of the second partition.
```
fdisk -l /dev/mmcblk0

>> Device       Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type
>> /dev/mmcblk0p1    64,0,1      1023,3,32         8192     532479     524288  256M  c Win95 FAT32 (LBA)
>> Partition 1 does not end on cylinder boundary
>> /dev/mmcblk0p2    64,0,1      64,0,1          532480   11018240   10485761 5120M 83 Linux
>> Partition 2 does not end on cylinder boundary
>> /dev/mmcblk0p3    128,0,11    1023,3,16     11018250   62521343   51503094 24.5G 83 Linux
```
The last sector of the second partition is 11018240. We add 5 sectors to this
value to know the number of sectors to copy:
```
cd /mnt/mmcblk0p3
sudo dd if=/dev/mmcblk0 of=user_env_2021_08_23.img bs=512 count=$((11018240 + 5))
sudo tar -czf user_env_2021_08_23.img.tar.gz user_env_2021_08_23.img
```
Now, we need the administrator rights to configure the PiSeduce resource manager in order to make our
new image available to all users.