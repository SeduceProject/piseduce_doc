---
layout: post
title: Brief Explanation of the Deployment Process
subtitle: Demystifying Deployment States
category: User Guide
index: 2
---
When users reserve Raspberry Pis, called nodes, the PiSeduce resource manager deploys an environment on the selected
nodes. This deployment requires a sequence of steps that is executed to install and configure every environment. Every
step has a name to identify the operation in progress. The sequence of operations can change with the updates but the
main process is the following (state names are in brackets):
* At first, the manager turns on the node to start it using PXE network boot (`boot_conf`, `turn_off`, `turn_on`,
  `ssh_test`). The first boot is over a NFS filesystem. The manager waits for the SSH connection is enabled.
* From the SSH connection, the image of the operating system to install is written to the SD card (`env_copy`,
  `env_check`). Then, the data partition on the SD card is increased. During this step, the partition is deleted and a
  bigger one is created (`delete_partition`, `create_partition`, `mount_partition`, `resize_partition`,
  `wait_resizing`).
* Now, the system is ready to be customized. The manager configures the hostnames of the environments and copying its
  SSH key (`system_conf`) to configure the root access.
* Then, the boot files of the environment are copied to the TFTP server of the manager (`boot_files`). These files are
  required to properly restart nodes. After the copy, nodes are rebooted.
* The manager waits for the SSH connection (`ssh_test`).
* If users ask for updated environments, the operating systems are updated and the boot files are copied again to the
  TFTP server (`system_update`, `boot_update`). Otherwise, nothing is done during these states.
* The last step is the configuration of the user accesses. The password of the default user of the deployed operating
  system is set and the user SSH keys are copied to enable root access (`user_conf`).

Some deployment states have timeout to detect failures. When the timeout expires, the node goes to the `lost` state and
the deployment is stopped. Users can hard reboot the nodes in the `lost` state to try to resume the deploy process. If
the *hard reboot* reconfiguration fails and the nodes is in the `lost` state again, users have to use the *deploy again*
reconfiguration to start the deployment process from the beginning.

**NOTE**: If users reserve nodes without configuring them, the nodes stay reserved, and so, they are not available to
other users. It is important to destroy the reservation even if the nodes are not configured. As these nodes will not
appear in the manage page, users have to go to the configure page to display all reserved nodes that are not configured.
From this page, they have to click on the *Cancel the reservation* button to destroy their reservations.
