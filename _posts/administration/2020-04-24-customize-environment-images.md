---
layout: post
title: Create your Own Environments
subtitle: Customize Operating System Images
category: Administration
index: 2
---

In order to make a wide variety of projects achievable, the resource manager must provide users with different
environments. These environments allow users to quickly test different configurations or to easily access to multiple
resources. A simple way to create different environments is the modification of an existing operating system image, for
example, by adding packages. In this article, we will modify the Raspbian&nbsp;Lite operating system image to install a
web terminal [ttyd](https://github.com/tsl0922/ttyd){:target="_blank"} available on the port 8080 of the node.

### Download the Raspbian image
```
wget https://downloads.raspberrypi.org/raspbian_lite_latest -O raspbian-lite.img.gz
gunzip raspbian-lite.img.gz
```
After decompressing the archive, we get the file *raspbian-lite.img*.

### Increase the size of the Raspbian image
In this example, we increase the size of the image by 1&nbsp;GB. Take care of increasing as little as possible the image
size because the deployment time is heavily dependent on this size.
* Append zeros to the image file
```
dd if=/dev/zero bs=1M count=1024 >> raspbian-lite.img
```
* Expand the partition  
Delete the second partition, then, create a partition with the whole space. Note the value of the
fist sector of the second partition before deleting it. Replace the first_sector by the value of the first sector of
the second partition.
```
fdisk -u raspbian-lite.img
p; d; 2; n; p; 2; first_sector; ''; w;
```
* Mount the partition  
Use the loop device given by the first command (`losetup -f`), it is a free loop device.
```
sudo losetup -f
sudo losetup -P /dev/loop1 raspbian-lite.img
sudo mount /dev/loop1p2 mount_dir/
```
* Resize the partition
```
sudo resize2fs /dev/loop1p2
```
Now, the partition mounted on the `mount_dir` directory is 1&nbsp;GB bigger. We are ready to add our stuffs.

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
* chroot to the Raspbian system
```
cd mount_dir
mount --bind /proc proc
mount --bind /sys sys
mount --bind /dev dev
chroot .
```
* Update the system and install additional packages
```
apt update && apt -y dist-upgrade
apt install build-essential cmake git libjson-c-dev libwebsockets-dev
```
* Build ttyd
```
cd /root/ttyd && mkdir build && cd build
cmake ..
make
cp ttyd /usr/bin/
```
* Run the ttyd daemon at the startup by editing the `/etc/rc.local` file. Append the following line:
```
ttyd --credential myuser:mypassword -p 8080 bash -x &> /dev/null &
```
Run the program as a background task to ensure the startup process does not stuck on the command.

### Exit the system
We have finished making changes of the Raspbian image.
```
# exit the chroot
exit
umount mount_dir
```
Do not forget to compress the new system image with the `tar` utility and the gzip compression option `-z` before adding
it to the resource manager. To register the environment, follow this [guideline](/2020-04-23-add-default-environments).

### Environment images for Raspberry Pi 3
The interesting feature of the Raspberry Pi 3 is the network boot is enabled by default. Indeed, if the Pi&nbsp;3 does
not find the `bootcode.bin` file at the boot time, it initiates the PXE boot sequence. So, one way to ensure the
Raspberry always starts the network boot sequence is to modify each environment images to remove the `bootcode.bin`.
This file belongs to the first partition of system images, also called, the boot partition.
