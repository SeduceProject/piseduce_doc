---
layout: post
title: First Use of the Resource Manager
subtitle: Deploy environments on Raspberry Pi
category: User Guide
index: 0
---

To access to the resource manager, users must create an account. After signing in, the resource manager page comes up.

![alt Resource Manager Home Page](/img/deployment_interface.png# bordered)

This page is divided into three sections: the selected nodes, the node states, the user deployment information. The
current resources (nodes) available to users are displayed at the middle part of the page. Every resource is represented
by a square with the node name, its IP address and its state. Nodes in the *in_use* state are currently used by users.
So, they can not be reserved until they change to the *free* state. To use *free* nodes, users select them by clicking
on their square. Names of selected nodes appear at the top of the interface in the *Selected nodes* section. To reserve
the selected resources, users must click on the *Deploy* button. The next step is to fill the deployment form.

![alt Deployment Form](/img/deployment_form.png# bordered)

At the top of the form, the selected node names are reminded. To start the node configuration, users must provide the
following information (**required fields**, *optional fields*):
* **Environment** - the environment image to deploy image that includes the operating system with, possibly, specific
  softwares (for example, an HTTP server).
* **Additional Free Space** - this parameter is used to limit the size of the system partition, in particular, when
  users planned to create their own environment image. Mostly, the default value *Whole SD_CARD* should be used.
* **Name** - the name of the deployment helps users to organize their deployments.
* *System Password* - this password allows to secure the node access. For example, this password is used for SSH
  connections to the *pi* user of the raspbian buster environment. If this field is blank, random passwords are
  generated.
* **Duration** - the duration of the experiment. After this period, the deployment will be destroyed and the nodes go back
  to the *free* state.
* *SSH Public Key* - this SSH key, if provided, will be added to the authorized keys of the root user of the system.
* *Init Script* - this script is executed on the deployed system at the very end of the deployment.

To start the deployment, users must click on the *Deploy* button. The progress of the deployment can be monitored from
the node states section.