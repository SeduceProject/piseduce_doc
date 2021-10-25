---
layout: post
title: PiSeduce Resource Manager Basis
subtitle: Global View of the Resource Manager
category: Administration
index: 1
---

The PiSeduce Resource Manager is a Python reservation tool that manages Raspberry Pi 3 and Pi 4.
This software allows users to reserve Raspberrys and deploy preconfigured environments on their
boards. The reservations have limited duration in order to share the resources available.
Environments are Raspberry operating systems customized to meet the user requirements, for example,
using a Web IDE as Cloud9. Currently, there are three proposed operating systems: Raspbian OS,
Ubuntu and piCore (or tinyCore), a minimalist operating system.

Raspberrys before the Raspberry Pi 3 can not be used with our resource manager because they do not
implement the PXE boot process. This network boot allows the manager to choose the OS to boot on the
Raspberrys.

The PiSeduce resource manager consists of two projects: the
[piseduce_webui](http://github.com/seduceproject/piseduce_webui){:target="_blank"} project and the
[piseduce_agent](http://github.com/seduceproject/piseduce_agent){:target="_blank"} project. These both
projects are hosted on GitHub.

The piseduce_webui project is the web interface of the resource manager. It also manages the user
accounts to secure access to the resource manager.

The piseduce_agent project manages the user reservations and the resources of the infrastructure,
e.g., the Raspberrys. To manage the Raspberrys, the agent can connect to them via SSH connections.

In order to manage a large amount of resources, one piseduce_webui can be connected to several
piseduce_agents. As the agents are connected to the ressources and they have the user reservations,
they can continue to deploy the user environments even if they lost connectivity to the
piseduce_webui.

The picture below summarizes the running of the piseduce_webui and several piseduce_agents.

[![alt Resource Manager Global View](/img/global_view.png# bordered)](/img/global_view.png){:target="_blank"}

The communication between the piseduce_webui and the piseduce_agent uses the agent API. This API
allows to insert data in the agent database and manage the Raspberrys. The agent database stores the
user reservations and the infrastructure description, that is to say, the Raspberrys and the
properties which are required to install the environments.

The deployment of environments on the Raspberrys are done by the agent executor. During this
process, the environment is copied on the SDCARD of the Raspberry and configured to allow users
to execute SSH connections to their Raspverrys. After the deployment, users have root access to
their machines.

The picture below describes the communnication between the piseduce_webui and the piseduce_agent
during the reservation process.

[![alt Reservation Scenario](/img/scenario.png# bordered)](/img/scenario.png){:target="_blank"}
