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

![alt User Deployment Interface](/img/deployment_information_1.png# bordered)

The *More Info* panel allows users to execute three operations:
* The *Hard Reboot* operation power off and on the selected nodes.
* The *Deploy again* operation starts again the deployment of the environment from the beginning for the selected nodes
  only.
* The *Release Nodes* operation free the selected nodes. The nodes will no longer be part of the deployment.

Information about the nodes can be displayed by clicking on node names. The properties available may be different from
one cluster to another one.

![alt User Deployment Interface](/img/deployment_information_2.png# bordered)

The first section gives information to connect to the node over SSH. The second one displays node properties:
* The node state in order to know whether the node is currently being deployed or the node is deployed
* The environment deployed on the node
* The node identifier that is used during the PXE boot
* The node model, for example, *RPI3B+* for Raspberry Pi 3 Model B+
* The link to access the node web interface if the deployed environment includes a web server
* The number of the switch port
* The node IP addresses (public and private) and the public SSH port

Below the node information, four operations can be executed: the *Hard Reboot* and the *Deploy again* operations
described above and two more operations:
* The *Show Password* operation shows the password used to secure access (SSH and web servers) to the nodes 
* The *Save Environment* operation that dumps the partitions of the selected node to an image file that could be
  deployed on nodes in the future deployments. Please read [this article](/2020-04-23-create-your-own-environments)
  before executing this action.

Both the *Hard Reboot* and the *Deploy again* actions can be used when user deployments are stucked or have failed. If
the *Hard Reboot* action is executed on a node during a deployment, the deployment process will continue after the
reboot.