---
layout: post
title: Offer Users New Environments
subtitle: Registering Environment Images in the Resource Manager
category: Administration
index: 3
---

When users reserve nodes from the PiSeduce resource manager, they have to choose the environment that will be deployed
on their nodes. This environment contains the operating system and, usually, additional specific packages. By default,
the PiSeduce resource manager offers only one environment: the
[Raspbian&nbsp;lite](https://www.raspberrypi.org/downloads/raspbian/){:target="_blank"} operating system without
additional package. For the most efficient use of the Raspberry cluster, administrators can register other environments
with different operating systems or additional installed packages. See this
[article](/2020-04-24-customize-environment-images) to customize an existing operating system image. The customized disk
image has to be compressed with the `tar` utility and the gzip compression option `-z`. The system images are located
in the environment directory defined in the `cluster_desc/main.json` file by the value of the `img_dir` key.

In most cases, system images for Raspberry Pi are compressed with the `gzip` utility. As the PiSeduce resource manager uses
the `tar` utility to manage system images, administrators must usually compress again the downloaded images. To check
the system images are well compressed, use the command `tar -tvf piCore-10.0beta12b.img.tar.gz`. The output should be
the name of the file included in the archive. To compress system images, use `tar czf piCore-10.0beta12b.img.tar.gz
piCore-10.0beta12b.img`. The result should be a file with the `.tar.gz` extension.

The registration of the new image as an environment is done by creating a *JSON* file in the `cluster_desc/environments`
directory. At the startup, the resource manager scans the files of the `environments` directory and adds properly
configured environments to the list of the user environments. The content of the *JSON* file is explained in this
[post](/2020-04-24-manager-configuration-files/#environment-description).

After adding or updating *JSON* files of the `environments` directory, the PiSeduce services (*pifrontend* and
*pitasks*) have to be restarted.

**Administrator tips for Raspberry Pi 3**  
To enable the PXE boot of Raspberry Pi 3, the file `bootcode.bin` **must not** belong to the `/boot` partition. The file
`bootcode.bin` exists in the first partition of operating system images designed for Raspberry. So, to avoid the copy of
this file in your Raspberry Pi, you can delete this file before compressing operating system images with `tar`.

In the following example, we delete the `bootcode.bin` file of the `2019-09-26-raspbian-buster-lite.img` image:
```
# Get the first loop device available
sudo losetup -f
>> /dev/loop3
# Mount the first partition of the image file
sudo losetup -P /dev/loop3 2019-09-26-raspbian-buster-lite.img
sudo mount /dev/loop3p1 mount_dir/
# Delete the bootcode.bin
sudo rm mount_dir/bootcode.bin
# Free the loop device
sudo umount mount_dir
sudo losetup -d /dev/loop3
```

Now, the `2019-09-26-raspbian-buster-lite.img` image can be safely used by the PiSeduce resource manager. We just have
to compress it with `tar -czf 2019-09-26-raspbian-buster-lite.img.tar.gz 2019-09-26-raspbian-buster-lite.img`.
