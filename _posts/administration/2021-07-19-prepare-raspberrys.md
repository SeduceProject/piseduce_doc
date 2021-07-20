---
layout: post
title: Prepare your Raspberrys
subtitle: Configure the PXE boot
category: Administration
index: 1 
---

The main hardware requires to set up a PiSeduce cluster is a PoE switch and at least eight
Raspberrys. A more precise list of the hardware can be found in this
[article](/2020-05-28-picluster-setup-from-scratch-ep1). In PiSeduce clusters, the PiSeduce Resource
Manager is able to install operating systems on the Raspberrys by using the network PXE boot, also
called, Ethernet boot. This boot option is not enabled by default so we have to activate it. As this
specific boot configuration is heavily dependent of the Raspberry Pi model, we explain how to set up
the PXE boot of two models: the Raspberry Pi 3B+ and the Raspberry Pi 4B. Older Raspberrys as
Raspberry Pi 2 are probably not compatible with our PiSeduce cluster because they do not accept PoE
HAT and PXE boot.

### Network configuration of Raspberry Pi 3B+
  For Raspberry Pi 3B+, the boot sequence tries to load the `bootcode.bin` file. If this file is not
  found, the Raspberry will initialize the network boot sequence. So, the network configuration is
  done by deleting the `bootcode.bin` file of the boot partition (the first partition of the SDCARD)
  or by inserting an empty SDCARD in the Raspberry.
  
  To delete the `bootcode.bin` file from Raspberry distribution images, you can mount the first
  partition of the image and delete the file. In the following example, we delete the `bootcode.bin`
  file of the *2019-09-26-raspbian-buster-lite.img* image (commands are executed from the root
  account):
  ```
  # Get the first loop device available
  losetup -f
  >> /dev/loop3
  # Mount the first partition of the image file
  losetup -P /dev/loop3 2019-09-26-raspbian-buster-lite.img
  mount /dev/loop3p1 mount_dir/
  # Delete the bootcode.bin
  rm mount_dir/bootcode.bin
  # Free the loop device
  umount mount_dir
  losetup -d /dev/loop3
  ```
### Network configuration of Raspberry Pi 4B
  For Raspberry Pi 4B, the boot sequence configuration is written in the Raspberry EEPROM and the
  default boot is the SDCARD boot. So, we have to update the EEPROM to select the network boot. This
  operation can be done from the Raspbian operating system. Follow the next steps to configure the
  network boot:
  * Install the Raspbian operating system on the Raspberry
  * Update the operating system: `apt update && apt -y dist-upgrade`
  * Install the EEPROM tool: `apt install rpi-eeprom`
  * Copy the EEPROM file: `cp /lib/firmware/raspberrypi/bootloader/critical/pieeprom-2020-04-16.bin
    pieeprom.bin`
  * Extract the EEPROM configuration: `rpi-eeprom-config pieeprom.bin > bootconf.txt`
  * Modify the boot order variable of the `bootconf.txt` to `BOOT_ORDER=0x12`
  * Generate a new EEPROM file: `rpi-eeprom-config --out netboot-pieeprom.bin --config bootconf.txt
    pieeprom.bin`
  * Update the EEPROM: `rpi-eeprom-update -d -f netboot-pieeprom.bin`
  * Then, start every Raspberry to configure from this SDCARD and execute the last command:
  `rpi-eeprom-update -d -f netboot-pieeprom.bin`.

  On recent systems, the command `rpi-eeprom-config` has the `--edit` option to modify the
  *BOOT_ORDER* value without extracting the EEPROM file.
  ```
  rpi-eeprom-config --edit
  BOOT_ORDER=0x12
  Ctrl-X
  Y
  reboot
  ```
  To save time, you can install the raspbian OS in one SDCARD and move the SDCARD from one
  Raspberry Pi 4 to another one. You only have to execute the commands without to install and
  update the raspbian OS.

### Connect the PoE HAT
In order to power on the Raspberrys from the PoE support of the switch, we connect PoE HAT to every
Raspberry.

![alt PoE HAT](/img/raspi_w_poe.png# bordered)

Now, we physically connect Raspberrys to the switch. If the PoE port of the switch is on, the
Raspberry should be powered on.
