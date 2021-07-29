---
layout: post
title: Install the PiSeduce Resource Manager from Scratch
subtitle: Raspbian OS Complete Customization
category: Behind the Scenes
index: 2
---
The creation of PiClusters, that is to say, Raspberry clusters managed by the PiSeduce resource
manager, is done in two steps: the purchase of the cluster hardware and the configuration of the
switch and the Raspberrys. The first step is described in this previous
[article](/2021-07-23-picluster-shopping-list/) and the second step is described here. Indeed, in
this article, we show the installation of the PiSeduce resource manager from the downloaded Raspbian OS
(32 bits or 64 bits). To quickly install the PiSeduce resource manager from our Raspberry image, see
this [article](/2021-07-20-manager-installation/).

### Before starting the resource manager installation
Obviously, the first step is to connect all the cluster hardware:
* Connect PoE HAT on the top of Raspberrys
* Insert SDCARDs inside Raspberrys
* Connnect Raspberry to the switch with Ethernet cables
* Plug the switch into an electrical outlet

After this step, we are ready to configure the Raspberry Pi 4 as described in this
[article](/2021-07-19-prepare-raspberrys/).

Then, we need to configure the switch in order to manage it from the resource manager as described
in this [article](/2021-07-19-prepare-the-switch/).

### Download the Raspbian OS
We choose to install the resource manager on the Raspbian OS because it is the smallest Raspberry
operating system. Moreover, this system is very popular and easy to configure. We can download the
Raspbian OS from:
* the [download page](https://downloads.raspberrypi.org/raspios_armhf/images/){:target="_blank"} of
  the 32-bit versions (armhf images).
* the [download page](https://downloads.raspberrypi.org/raspios_arm64/images/){:target="_blank"} of
  the 64-bit versions (arm64 images).

In this article, we choose to download the 64-bit image *2021-05-07-raspios-buster-arm64.zip*.

### Write the OS image
After downloading the Raspbian OS image, we write this image on the SDCARD. If the SDCARD have
already been used, we prefer to format it before. Do not forget to umount the mounted SDCARD
partitions before writing the SDCARD. In this example, the SDCARD is in */dev/sdb* and two partitions
*/dev/sdb1* and */dev/sdb2* are automatically mounted:
```
# Uncompress the image
unzip 2021-05-07-raspios-buster-arm64.zip
# Unmount the partitions
sudo umount /dev/sdb1
sudo umount /dev/sdb2
# Format the SDCARD
sudo mkfs.vfat -I /dev/sdb
# Write the image to the SDCARD
sudo dd if=2021-05-07-raspios-buster-arm64.img of=/dev/sdb bs=4M conv=fsync
```
As we want to connect with SSH into the Raspberry, we add the file *ssh* in the boot partition of
the SDCARD. In this way, the SSH server will start at the startup:
```
mkdir mount_dir
sudo mount /dev/sdb1 mount_dir
sudo touch mount_dir/ssh
sudo umount mount_dir
```

### (Optional) Setting a fixed IP to the pimaster by editing the SDCARD
In the final configuration, the pimaster that hosts the PiSeduce resource manager also runs a DHCP
server and a PXE boot server. Consequently, we set a fixed IP to this Raspberry. We configure the
pimaster IP by editing the `/etc/dhcpcd.conf` file in the second partition of the SDCARD:
```
sudo mount /dev/sdb2 mount_dir
sudo vim mount_dir/etc/dhcpcd.conf
```
We uncomment the two following lines of the section *Example static IP configuration:*:
```
interface eth0
static ip_address=192.168.0.10/24
```
Then, we replace the default IP *192.168.0.10* by the IP *48.48.0.254*:
```
interface eth0
static ip_address=48.48.0.254/24
```
After this modification, we umount the partition and boot the Raspberry:
```
sudo umount mount_dir
```
If required, the pimaster can be connected to a WIFI network by following this
[article](/2021-07-20-manager-installation#wifi-connection).

### Prepare the pimaster
To continue the installation, we have to connect the pimaster to the Internet. Then, we connect with
SSH with the user *pi* and the password *raspberry* (the pimaster IP is *192.168.77.9*):
```
ssh -l pi 192.168.77.9 
```
Then, we update the operating system:
```
sudo su
apt update
apt -y dist-upgrade
apt -y autoremove
```
We configure the SSH access from key authentication by copying our SSH key in the
`/root/.ssh/authorized_keys` file of the *pi* user by using the `ssh-copy-id` command from our computer:
```
ssh-copy-id pi@192.168.77.9
```
To configure the SSH *root* access from key authentication, we log into the pimaster with the *pi*
user and copy the SSH key to the root account.
```
ssh pi@192.168.77.9
sudo su
mkdir /root/.ssh
mv /home/pi/.ssh/authorized_keys /root/.ssh/
chmod 700 /root/.ssh/
chown root.root /root/.ssh/authorized_keys
```
Log out from the *pi* user and test the SSH *root* access:
```
ssh root@192.168.77.9
```
We like to change the hostname of the pimaster because the SHELL prompt is modified when we are
connected via SSH. Moreover, we disable the PAM authentication of the SSH server (*nano* text editor
can be used instead of *vi*):
```
echo 'pimaster' > /etc/hostname
# change the line 'UsePAM yes' to 'UsePAM no'
vi /etc/ssh/sshd_config
reboot
```
After rebooting the pimaster, we log in with the *root* user:
```
ssh -l root 192.168.77.9
```
We no longer need the *pi* user so we delete this account:
```
deluser --remove-all-files pi
```

### Configuring the NFS server
The resource manager configures the Raspberrys by copying new environments on their SDCARD. To
execute this copy, the manager boots the Raspberrys on a NFS filesystem hosted on the pimaster. To
configure the NFS server, we need to install additional packages (*pv* and *vim*) on the pimaster
before cloning its filesystem. In that way, the installed packages will be also available from the
Raspberrys which will boot from the NFS filesystem:
```
apt -y install pv vim
```
**TODO**: Remove the swap file before the system copy
To create the NFS filesystem on the pimaster, we can make a copy of the existing filesystem in the directory
`/nfs/raspi`:
```
mkdir -p /nfs/raspi
rsync -xa --progress --exclude /nfs / /nfs/raspi
```
Then we configure the NFS filesystem to enable SSH communications. Indeed, the pimaster has to copy
files on the Raspberrys booted from the NFS system and these Raspberrys must also be abled to copy
files on the pimaster:
```
ssh-keygen
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
# exit the chroot
exit
# Authorize the NFS system to connect to the pimaster over SSH
cat /nfs/raspi/root/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
umount dev sys proc
```
Now, the NFS filesystem is ready. We install the NFS server:
```
apt -y install nfs-kernel-server
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
Since the pimaster file system has been cloned, we can install all the required packages (see more details about the
packages [here](#explanations-concerning-the-additional-packages)):
```
apt -y install dnsmasq git sqlite3 nfs-kernel-server python3-pip pv snmp vim
```
As the Raspberrys managed by the resource manager use the pimaster as a gateway to the other
networks, we need to enable IP forwarding on the pimaster:
```
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
```
To provide Raspberrys with Internet, we need to configure the IP masquerade on the network interface
with the Internet access. As the masquerade command have to be executed at the startup, we add it to
the startup script `/etc/rc.local`. We use the `wlan0` interface to access the internet so we add the
following line (before the `exit 0` line):
```
iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
```

### Preparing TFTP/PXE files
To manage the Raspberrys, the resource manager configures Raspberry PXE boot directories before
turning them on. In that way, it can choose to boot the Raspberry over the NFS filesystem or from
their SDCARD. The content of the PXE boot directories consists of:
* boot files to load the kernel
* home made `bootcode.bin` file to start the PXE boot of the Raspberry Pi 3
* a custom `cmdline.txt` to tell the Raspberry to boot over the NFS filesystem

Let us begin with the creation of the *tftpboot* directory that includes the boot files:
```
mkdir /tftpboot
cp -r /boot /tftpboot/rpiboot_uboot
rm /tftpboot/rpiboot_uboot/bootcode.bin /tftpboot/rpiboot_uboot/cmdline.txt
```
Download the [bootcode.bin file](/public_data/bootcode.bin) to the *tftpboot* directory:
```
cd /tftpboot
wget https://doc.seduce.fr/public_data/bootcode.bin
```
Then, download the [cmdline.txt template](/public_data/cmdline.txt) and edit the file to replace the IP address
by the IP address of the pimaster:
```
cd /tftpboot/rpiboot_uboot/
wget https://doc.seduce.fr/public_data/cmdline.txt
# Check the IP of the nfsroot command is the pimaster IP 48.48.0.254
vim cmdline.txt
```

### Configuring the DHCP/TFTP server
We use the *dnsmasq* service to create both the DHCP server and the TFTP server which allows PXE
boots. In the following example, the pimaster IP is *48.48.0.254* and the DHCP gives addresses
belonging to the network *48.48.0.0/24*:
```
listen-address=48.48.0.254
interface=eth0
bind-interfaces
log-dhcp
enable-tftp
dhcp-boot=/bootcode.bin
tftp-root=/tftpboot
pxe-service=0,"Raspberry Pi Boot"
tftp-no-blocksize
no-hosts

dhcp-range=48.48.0.0,static,255.255.255.0
dhcp-option=23,64
```

### Installing the PiSeduce resource manager
The PiSeduce resource manager is written in Python3.7. We install Python with the other packages at the beginning of
this article so we just have to get the code from github:
```
cd /root
git clone http://github.com/remyimt/piseduce_webui
git clone http://github.com/remyimt/piseduce_agent
```
and install the Python modules by using pip3:
```
python3 -m pip install --upgrade pip
cd /root/piseduce_webui
python3 -m pip install -r requirements.txt
cd /root/piseduce_agent
python3 -m pip install -r requirements.txt
```

After installing the resource manager, we have to create the databases:
```
cd /root/piseduce_webui
python3 init_database.py
cd /root/piseduce_agent
python3 init_database.py config_agent.json
```
The environments deploy on the Raspberrys are stored at the pimaster. The location of the
environment directory is defined by the property `env_path` of the `config_agent.json` file. The
default value of this property is `/root/environments`. So, we create this directory and upload the
Raspbian Lite environment in this directory:
```
mkdir /root/environments
cd /root/environments/
wget http://dl.seduce.fr/raspberry/piseduce/2020-08-20-raspios-buster-armhf-lite.img.tar.gz
```
To add this environment in the resource manager, we insert several rows to the `test-agent.db`
database:
```
cd /root/piseduce_agent/
sqlite3 test-agent.db
insert into rasp_environment values("raspbian_buster_32bit", "img_name", "2020-08-20-raspios-buster-armhf-lite.img.tar.gz");
insert into rasp_environment values("raspbian_buster_32bit", "img_size", "1845493760");
insert into rasp_environment values("raspbian_buster_32bit", "sector_start", "532480");
insert into rasp_environment values("raspbian_buster_32bit", "ssh_user", "root");
insert into rasp_environment values("raspbian_buster_32bit", "web", "false");
.exit
```

To share sensitive information as passwords, the piseduce_webui and the piseduce_agent have to use
the same security key. The name of this key is defined in the `config_agent.json` file by the
property `key_file`. To generate this key, we use the `python3 generate_password_key.py` script of the
piseduce_webui project and share this key with the piseduce_agent:
```
cd /root/piseduce_webui
python3 generate_password_key.py
cp secret.key /root/piseduce_agent/
```
Then, we create a systemD service to manage the webui:
```
cp admin/*.service /etc/systemd/system/
systemctl enable webui.service
```
To manage the two piseduce_agent services (*agent_api* and *agent_exec*), we copy the service
description files `piseduce_agent/admin/*.service` to the `/etc/systemd/system` directory and
configure it to start at boot:
```
cd /root/piseduce_agent
cp admin/*.service /etc/systemd/system/
systemctl enable agent_api.service
systemctl enable agent_exec.service
```
We start all services and check the services are running:
```
service webui start
service agent_api start
service agent_exec start
service webui status
service agent_api status
service agent_exec status
```

Both *agent_api* and *agent_exec* service are responsible for managing the Raspberrys. The *webui*
service is the web interface of the PiSeduce resource manager. We connect to this interface on the
port 9000 of the pimaster
([http://pimaster.local:9000](http://pimaster.local:9000){:target="_blank"}) to use the resource
manager. The administrator can log in with the username *admin@piseduce.fr* and the password
*piseduceadmin* to manage the cluster. To complete the configuration of the PiSeduce resource
manager, we follow this article of the administration guide from the [Switch IP
Configuration](/2021-07-20-manager-installation/#switch-ip-configuration) section.

### (Optional) Enable the SSH root acess from password authentication
To log into the pimaster by using the *root* user with a password, the first step is to set a
complex password to the *root* user ([online password
generators](https://passwordsgenerator.net/){:target="_blank"} can help to generate good passwords).
After loging in with the *root* user, enter the `passwd` command and type your password twice. The
password of the *root* user is set. Then, we enable the root login with SSH by modifying the
`/etc/ssh/sshd_config` file. We uncomment the line `PermitRootLogin prohibit-password` and change
the value to `PermitRootLogin yes`. We complete the SSH configuration by restarting the SSH server
`service ssh restart`.

**WARNING**: Even with complex passwords, SSH key authentication is more secure than password
authentication. Try not to use the password authentication on the pimaster.

### Installation Size
The disk space used by this installation is:
* 7 Gb on the Raspbian 64-bit operating system
* 4 Gb on the Raspbian Lite 32-bit operating system

### Create a Raspberry image from this installation
**NOTE**: To reduce the size of the system image, the installation of the resource manager has to be
done in a small partition (on the SDCARD). To reduce the system partition size, we have to prevent
the auto-resize operation of the Raspbian system by removing the `init=` option of the `cmdline.txt`
file (located in the boot partition). Then, we expand the system partition in order to have a
partition size equal to the installation size. The expanding of the partition is described in this
[article](http://localhost:4000/2021-07-10-create-your-own-environments/#information-about-the-second-partition).

To deploy the resource manager in other Raspberrys without doing again this installation, we create
a system image of the SDCARD. Before making this image, we clean the system by:
* removing the WIFI configuration. We delete the network section of the
  `/etc/wpa_supplicant/wpa_supplicant.conf` file.
* removing our SSH key from the /root/.ssh/authorized_keys. **Do not delete the public key of NFS
  system!**

Then, follow this
[article](/2021-07-10-create-your-own-environments/#create-an-archive-of-the-raspbian-os) to create
the compressed image of the file system.

### Explanations concerning the additional packages
A brief description of the additional packages to install on the pimaster:
* **dnsmasq** is used to create both the DHCP server and the PXE/TFTP server.
* **git** is used to download/update the PiSeduce resource manager.
* **sqlite3** is used to manage the SQLite databases.
* **nfs-kernel-server** is the NFS server. To configure the pislaves, we boot them from a NFS file
  system hosted on the pimaster.
* **python3-pip** is the Python 3 package manager.
* **pv** is used to monitor the download of the operating system while deploying environments on the
  pislaves.
* **snmp** is used to communicate with the switch.
* **vim** is my favourite text editor.