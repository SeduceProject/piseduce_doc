---
layout: post
title: Brief Explanation of the Deployment Process
subtitle: Demystifying Deployment States
category: User Guide
index: 42
---
When users reserve Raspberry Pis, called nodes, the PiSeduce resource manager deploys an environment on the selected
nodes. This deployment requires a sequence of steps that is executed to install and configure every environment. Every
step has a name to identify the operation in progress. The sequence of operations can change with the updates but the
main process is the following:
* At first, the manager turns on the node to start it using PXE network boot (`nfs_boot_conf`, `nfs_boot_off`,
  `nfs_boot_on`). The first boot is over a NFS filesystem. The manager waits for the SSH connection is enabled.
* From the SSH connection, the image of the operating system to install is written to the SD card (`env_copy`,
  `env_check`). Then, the data partition on the SD card is increased. During this step, the partition is deleted and a
  bigger one is created (`delete_partition`, `create_partition`, `mount_partition`, `resize_partition`,
  `wait_resizing`).
* Now, the system is ready to be customized. The manager configures account passwords and SSH access by copying SSH keys
  (`system_conf`, `user_conf`). By default, your SSH public key is installed on your environment.
* The last step is the execution of the user script and environment specific checks can be performed to test the proper
  functionning of the installed softwares (`user_script`, `deployed`).

If the process hangs on one of the states during deployments, users can try to hard reboot their nodes. The *Hard
Reboot* operation turns off and on the node. When the node has been rebooted, the deployment starts again in the last
registered state before rebooting. If the *Hard Reboot* does not fix the deployment, users can use the *Deploy Again*
operation. The latter starts the deployment process again from the beginning.  
**NOTE**: If users are nodes in the `initialized` state, they have to destroy their deployment. While nodes are in the
`initialized` state, the owner of the nodes and the other users can not use the nodes. These nodes are reserved but the
deployment form has not been sent. This state appears in the following case:
* From the home page, users select nodes and go to the deployment form by clicking on the *Deploy* button
* Users go back to the previous page (the home page) without using the *Cancel* button, they use the *Previous Page*
  button of their navigator.

When nodes remain blocked in a state for more than 300 seconds, this state changes to `lost`. Lost nodes are not
monitored by the resource manager. Users must try one of the two operations *Hard Reboot* or *Deploy Again* to fix their
deployment.

**Why is this happening ?**  
To avoid the user *Paul* takes the nodes of the user *John* while this one is filling the deployment form, the resource
manager puts nodes of the user *John* in the `initialized` state. So *Paul* can not reserve the *John*'s nodes.