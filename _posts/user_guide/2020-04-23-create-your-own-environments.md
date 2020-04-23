---
layout: post
title: Create your Own Environment Images
subtitle: Customized and Save your Environment
category: User Guide
index: 2
---

After successful deployments, users can perform actions on their nodes from the *More&nbsp;Info* panel. Thanks to
*Save&nbsp;Environment* actions, users can create an image file of the operating system deployed on one of their nodes.
This image file can be used as an environment to deploy on nodes. This action executes the following operations:
* Reading the partition table to determine the size of the used disk space. We consider the used space stops at the last
  sector of the last partition.
* Copy the used disk space to an image file. For this purpose, a new partition is created with sufficient space to copy
  the whole used data.
* The image file is compressed and stored in the resource manager node.
* The image file is imported into the system from the name provided by users.

Therefore, the size occupied by the partitions has to be as small as possible for two reasons:
* The size of the environment image will be smaller, and so, the deployment time will be reduced
* This operation needs to create an additional partition that has to be large enough to store the whole existing data

In order to limit the partition size, users can reduce the free space available on the node file system by using the
*Additional&nbsp;Free&nbsp;Space* field of the deployment form. To fill this field, users have to estimate the required
free space for installing new packages.  
**WARNING**: Users can not use *Save&nbsp;Environment* actions when *Additional&nbsp;Free&nbsp;Space* is set to
*Whole&nbsp;SD_CARD*. In this configuration, the operating system partitions occupy all the storage space.

After *Save Environment* actions, the new environment will be available with the default environments.
