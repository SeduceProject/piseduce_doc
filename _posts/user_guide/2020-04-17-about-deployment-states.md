---
layout: post
title: Brief Explanation of the Deployment Process
subtitle: Demystifying Deployment States
category: User Guide
---
When users reserve Raspberry Pis, called nodes, the PiSeduce resource manager deploys an environment on the selected
nodes. This deployment requires a sequence of steps that is executed to install and configure all the environments.
Every step has a name to identify the operation in progress. The sequence of operations can change with the updates but
the main process is the following:
* At first, the manager turns on the node to start it using PXE network boot. The first boot is over a NFS filesystem.
  The manager waits for the SSH connection is enabled.
* From the SSH connection, the image of the operating system to install is written to the SD card. Then, the data
  partition on the SD card is increased. During this step, the partition is deleted and a bigger one is created.
* Now, the system is ready to be customized. The manager configures account passwords and SSH access by copying SSH
  keys. By default, the SSH public key is installed on your environment.
* The last step is the execution of the user script and environment specific checks can be performed to test the proper
  functionning of the installed softwares.

If the process hangs on one of the states during deployments, users can try to hard reboot their nodes. The *Hard
Reboot* operation turns off and on the node. When the node has been rebooted, the deployment starts again in the last
registered state before rebooting. If the *Hard Reboot* do not fix the deployment, users can use the *Deploy
Again* operation. The latter start the deployment process again from the beginning.
**NOTE**: If users are nodes in the *initialized* state, they have to destroy their deployment. While nodes are in the *initialized* state, the owner of the nodes and the other users can not use the nodes. These nodes are reserved but the deployment form has not been sent. This state appears in the following case:
* From the home page, users select nodes and go to the deployment form by clicking on the *Deploy* button
* Users go back to the previous page (the home page) without using the *Cancel* button, they use the *Previous Page* button of their navigator.

**Why is this happening ?**  
To avoid the user *Paul* takes the nodes of the user *John* while this one is filling the deployment form, the resource manager puts nodes of the user *John* in the *initialized* state. So *Paul* can not reserve the *John*'s nodes.