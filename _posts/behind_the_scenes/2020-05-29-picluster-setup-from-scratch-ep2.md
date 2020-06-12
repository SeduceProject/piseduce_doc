---
layout: post
title: Create your PiSeduce Cluster from Scratch - Episode 2
subtitle: Configure the Software Stack
category: Behind the Scenes
index: 2
---
After connecting all the components, we are ready to start the configuration of the PiSeduce cluster. If you want to
quickly configure the pimaster without knowing the exact details of the pimaster configuration, see this
[artcile](/2020-05-27-create-your-own-cluster). The main steps of this configuration are: collecting pislave
information, installing management services on the pimaster and installing the PiSeduce resource manager on the
pimaster. Let us begin with the collect of the information about the pislaves.

## Collecting pislave information
In order to configure the management services running on the pimaster, we need information about the pislaves. The easy
way to retrieve these pieces of information is to install the
[Raspbian](https://www.raspberrypi.org/downloads/raspbian/){:target="_blank"} operating system on every slave (or
install it on one SDCARD and use this card in every pislave). The first required information is the pislave MAC
addresses which will be used to configure the DHCP server. You can retrieve the MAC adress of the Raspberry with the
command:
```
ifconfig | grep ether | awk '{ print $2 }'
```
The other information we need to retrieve is the ID of the pislave which will be used for the PXE boot. The ID can be
get with the command:
```
cat /proc/cpuinfo | grep "Serial" | awk '{print substr( $3, length($3) - 7, length($3) ) }'
```
The last information is the port number of every pislave. So, at the end, we should obtain a file that looks like this:
```
port: 1
mac: B8:27:EB:76:30:6B 
id: a67c64be

port: 2
mac: B8:27:EB:20:85:b9
id: 772306de

port: 3
mac: B8:27:EB:20:de:45
id: de23ff56
```

## Installing management services
### Preparing the pimaster operating system
After connecting all the components, we are ready to configure the pimaster. Install the
[Raspbian](https://www.raspberrypi.org/downloads/raspbian/){:target="_blank"} operating system without graphical
interface on the choosen Raspberry Pi and update the system:
```
sudo apt update && sudo apt -y dist-upgrade
```
Configure the SSH root access from key authentication by copying your SSH key in the `/root/.ssh/authorized_keys` file:
```
sudo nano /root/.ssh/authorized_keys
```
We like to change the hostname of the pimaster because the SHELL prompt is modified when we are connected via SSH:
```
echo 'pimaster' > /etc/hostname
```
A reboot is required to change the SHELL prompt. Log in with the root account to continue the configuration.

### Configuring the NFS server
The installation of new environments (operating systems with preconfigured additional packages) on the pislaves is a
two-steps procedure. The first step is the boot of the pislave over a NFS file system hosted by the pimaster. The second
step is the configuration of the recently installed operating system.

We need to install additional packages on the pimaster before cloning its file system. In that way, the installed
packages will be also available for pislaves which will boot from the NFS file system:
```
apt install pv vim
```
To create the NFS file system on the pimaster, we can make a copy of the existing file system in the directory
`/nfs/raspi`:
```
mkdir -p /nfs/raspi
rsync -xa --progress --exclude /nfs / /nfs/raspi
cat /root/.ssh/id_rsa.pub > /nfs/raspi/root/.ssh/authorized_keys
cd /nfs/raspi
mount --bind /dev dev
mount --bind /sys sys
mount --bind /proc proc
chroot .
echo '' > /etc/fstab
rm /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server
# Generate a new SSH keys for the NFS operating system
ssh-keygen
mkdir /root/boot_dir /root/fs_dir
echo 'nfspi' > /etc/hostname
exit
# Authorize the NFS system to connect to the pimaster over SSH
cat /nfs/raspi/root/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
umount dev sys proc
```
We disable the PAM module for the SSH server on the NFS file system. Edit the file '/nfs/raspi/etc/ssh/sshd_config':
```
UsePAM no
```
And, we increase the size of the swap file by editing the file `/nfs/raspi/etc/dphys-swapfile`:
```
CONF_SWAPSIZE=1024
```
Now, we can install the NFS service:
```
apt install nfs-kernel-server
```
Then, we export the file system via the NFS server. Start by editing the file `/etc/exports`:
```
/nfs *(rw,sync,no_subtree_check,no_root_squash)
```
Then, restart the NFS server:
```
exportfs -a
service nfs-kernel-server restart
# Check the NFS file system is properly configured
showmount -e
```

### Install the required services
As the pimaster file system has been cloned, we can install all the required packages (see more details about the
packages [here](#explanations-concerning-the-additional-packages)):
```
apt install dnsmasq git libffi-dev mariadb-client mariadb-server \
    nfs-kernel-server python3-mysqldb python3-pip pv snmp vim
```
As the pislaves use the pimaster as a gateway to the other networks, we need to enable IP forwarding on the pimaster:
```
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
```

### Preparing TFTP/PXE files
To manage the pislaves, the pimaster configures pislave PXE boot directories before turning them on. In that way, it can
choose to boot the pislaves over the NFS file system or from their SDCARD. The content of the PXE boot directories is
available [here](/public_data/tftpboot.tar.gz). Unzip the archive in the `/tftpboot` directory:
```
mkdir /tftpboot
tar xzf tftpboot.tar.gz -C /tftpboot
```
Configure the NFS boot by replacing the IP in all `/tftpboot/rpiboot_uboot_*/cmdline.txt` files by the IP of the
pimaster, e.g., *10.10.0.2*.
```
nfsroot=10.10.0.2:/nfs/raspi1,udp,v3 rw ip=dhcp root=/dev/nfs rootwait console=tty1 console=ttyAMA0,115200
```

### Configuring the DHCP/TFTP server
We use the *dnsmasq* service to create both the DHCP server and the TFTP server which allows PXE boots. To properly
configure the DHCP server, we need the MAC addresses of every pislave. In the following example, the pimaster IP is
*10.10.0.2* and the DHCP gives addresses belonging to the network *10.10.0.0*. Edit the file `/etc/dnsmasq.conf` and add
one line for every pislave containing its MAC address, its hostname and the IP address that will be provided by the
DHCP server:
```
listen-address=10.10.0.2
interface=eth0
bind-interfaces
log-dhcp
enable-tftp
dhcp-boot=/bootcode.bin
tftp-root=/tftpboot
pxe-service=0,"Raspberry Pi Boot"
tftp-no-blocksize
no-hosts

dhcp-range=10.10.0.0,static,255.255.255.0
dhcp-option=23,64

dhcp-host=B8:27:EB:76:30:6B,node1,10.10.0.11
dhcp-host=B8:27:EB:20:85:b9,node2,10.10.0.12
dhcp-host=B8:27:EB:20:de:45,node3,10.10.0.13
```

### Configuring the database
The PiSeduce resource manager stores information about the registrered users and their deployments in a database. We
choose to use the open source relational database *MariaDB*. To finish the installation of the database, we need to run
the following command:
```
mysql_secure_installation
```
Then, we create a database named *piseduce* and a new user named *pipi* which will be used by the resource manager. Log
in to mariadb-server with the *root* account `mysql -u root -p` and run the following commands (replace *totopwd* by
a new password):
```
CREATE DATABASE piseduce;
CREATE USER 'pipi'@'localhost' IDENTIFIED BY 'totopwd';
GRANT USAGE ON *.* TO 'pipi'@localhost IDENTIFIED BY 'totopwd';
GRANT USAGE ON *.* TO 'pipi'@'%' IDENTIFIED BY 'totopwd';
GRANT ALL PRIVILEGES ON piseduce.* TO 'pipi'@'localhost';
```
Now, all management services are properly configured. Restart all the services and check their status:
```
service dnsmasq restart
service nfs-kernel-server restart
service dnsmasq status
service nfs-kernel-server status
service mariadb status
```
If all services are running, we are ready to install the PiSeduce resource manager.

## Installing the PiSeduce resource manager
The PiSeduce resource manager is written in Python3.7. We install Python with the other packages at the beginning of
this article so we just have to get the code from github:
```
git clone https://github.com/remyimt/seduce_pp
```
The first thing is to replace the database password *DBPASSWORD* with the password of the *pipi* user in the
configuration file `seducepp.conf` by modifying the following line:
```
connection_url=mysql://pipi:DBPASSWORD@localhost/piseduce
```
Then, we need to create JSON files to describe your PiSeduce cluster infrastructure. At first, copy the template of the
`main.json` file to the `cluster_desc` directory:
```
cd seduce_pp
cp autoconf/files/main.json cluster_desc/
```
Edit this file and fill it according to your cluster configuration. A complete description of the configuration files is
available in this [article](/2020-04-24-manager-configuration-files#describing-the-piseduce-cluster){:target="_blank"}.
Be carefull, the pathes defined by the properties *env_cfg_dir* and *img_dir* must be absolute paths.

We also need to create one JSON file for every pislave. Copy the template of the node description in the
`cluster_desc/nodes` directory:
```
cp autoconf/files/node-default.json cluster_desc/nodes/nodes-1.json
```
Then, fill it with the information about the Raspberry connected to the port number 1. Use the information collected in
the [first&nbsp;section](#collecting-pislave-information) of this article. Refer to the previous
[article](/2020-04-24-manager-configuration-files#describing-the-piseduce-cluster) to obtain more information about this
description file.

The configuration of the PiSeduce resource manager is completed. Copy service description files in the
`/etc/systemd/system` directory and enable them to start at boot:
```
cp admin/*.service /etc/systemd/system/
systemctl enable pitasks.service
systemctl enable pifrontend.service
service pifrontend start
service pitasks start
```
Check the services are running:
```
service pifrontend status
service pitasks status
```
The *pitasks* service is responsible for deploying the user environments and the *pifrontend* service is the web
interface of the PiSeduce resource manager. Connect on the port 9000 of the pimaster
([http://pimaster.local:9000](http://pimaster.local:9000)) to use the resource manager. The administrator can log in
with the username *admin@piseduce.fr* and the password *piseduceadmin* to manage the user accounts. See this
[article](/2020-04-24-user-management) to learn more about user management.

## Explanations concerning the additional packages
A brief description of the additional packages to install on the pimaster:
* **dnsmasq** is used to create both the DHCP server and the PXE/TFTP server.
* **git** is used to download/update the PiSeduce resource manager.
* **libffi-dev** is a library required to install the [ttyd](https://github.com/tsl0922/ttyd){:target="_blank"} web
  terminal.
* **mariadb-client** and **mariadb-server** is the database used by the resource manager.
* **nfs-kernel-server** is the NFS server. To configure the pislaves, we boot them from a NFS file system hosted on the
  pimaster.
* **python3-mysqldb** and **python3-pip**: the resource manager is written in Python 3.7.
* **pv** is used to monitor the download of the operating system while deploying environments on the pislaves.
* **snmp** is used to communicate with the switch.
* **vim** is my favourite text editor.
