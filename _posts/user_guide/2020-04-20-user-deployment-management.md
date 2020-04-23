---
layout: post
title: Information and Management of User Deployments
subtitle: Play with my nodes after the deployment
category: User Guide
index: 1
---
After submitting a deployment to the PiSeduce resource manager, this deployment appears at the bottom of the main page
in the *Deployments* panel. In this panel, there is the deployment name followed by the names of nodes included in the
deployment. Below this information, there are two buttons. The *Destroy* button will delete the user reservation and
free the nodes which could be reserved by other users. The *More Info* button displays information about the nodes and
allows users to execute some actions on their nodes.

![alt User Deployment Interface](/img/deployment_information.png# bordered)

In the *More Info* panel, users will find for every node:
* Information about how to connect via SSH
* The link to access the node web interfaces if the deployed environment includes a web server
* The node identifier that may be useful for administrators
* The node IP addresses (public and private) and the public SSH port
* The node model, for example, *RPI3B+* for Raspberry Pi 3 Model B+
* The password to connect to services running on the nodes, for example, a SSH server or a web interface
* The node state in order to know whether the node is currently being deployed or the node is deployed

Moreover, in this panel, users can perform the following actions on nodes:
* *Hard Reboot* means the selected node is powered off and on
* *Deploy again* means the deployment of the environment will be start again from the beginning for the selected node
  only
* *Save Environment* means the partitions of the selected node will be dumped to an image file that could be deployed on
  nodes in the future deployments. Please read [this article](/2020-04-17-create-your-own-environments) before
  executing this action.

Both the *Hard Reboot* and the *Deploy again* actions can be used when user deployments are stucked or have failed. If
the *Hard Reboot* action is executed on a node during a deployment, the deployment process will continue after the
reboot.
