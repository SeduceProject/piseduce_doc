---
layout: post
title: Secure the PiSeduce Resource Manager
subtitle: SSH keys, agent configuration, switch
category: Administration
index: 8
---

The PiSeduce resource manager is hosted on a Raspberry that we call the pimaster. To limit the risk
of hacker intrusion into the resource manager, precautions must be taken even more if the resource
manager has been installed from the downloaded PiSeduce image ([ARMHF
32bit](http://dl.seduce.fr/raspberry/piseduce/piseduce-armhf-28-juil-2021.img.tar.gz) or [ARM64
64bit](http://dl.seduce.fr/raspberry/piseduce/piseduce-arm64-29-juil-2021.img.tar.gz)). Indeed, the
PiSeduce image contains SSH keys, agent authentication token, passwords that everybody knows.

**IMPORTANT**: All commands are executed on the pimaster with the **root** user.

### Secure the SSH access
To log into the pimaster, the default SSH login is with the `root` user and the password
`piseduceadmin`. It is important to change the `root` password and secure the SSH connection to the
pimaster:
* Change the root password by setting a more complex one. We can generate good passwords from
  [online password generator](https://passwordsgenerator.net/){:target="_blank"}:
  ```
  # Execute this command as root
  passwd
  ```
* Delete the `pi` user (normally this user is already deleted)
```
deluser --remove-all-files pi
```
* Generate new SSH keys for the pimaster
  ```
  rm /root/.ssh/id_rsa*
  ssh-keygen
  ```
* Generate new SSH keys for the NFS system
  ```
  cd /nfs/raspi/
  mount --bind /dev dev
  chroot .
  rm /root/.ssh/*
  ssh-keygen
  exit
  ```
* Configure the SSH connection between the pimaster and the NFS system
  ```
  cat /root/.ssh/id_rsa.pub > /nfs/raspi/root/.ssh/authorized_keys
  cat /nfs/raspi/root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys
  ```
* Add our SSH keys on the pimaster authorized keys by executing the following commands **from our
  local machine**:
  ```
  ssh-keygen
  ssh-copy-id root@pimasterIP
  ```
* Test the SSH connection to the pimaster does not ask for password (so the key authentication is
  working).
* Disable the SSH root login from password authentication by editing the `/etc/ssh/sshd_config` file
  and setting the `PermitRootLogin` property to `prohibit-password`. Then, restart the SSH daemon:
  `service ssh restart`.

### Secure the SNMP access to the switch
The SNMP access to the switch allows to turn off/on the PoE ports. This feature is used to control
the Raspberry, for example, by rebooting them. As everybody knowing the SNMP community can control
the switch, we have to set an IP filter to limit the machines that can use the SNMP. This filter
must be added when the community is created. In our Linksys switch, we go to the communities page
(Configuration > SNMP > Communities). Then, we add a community with the pimaster IP in the `IP
Address` field and the Read/Write rights. Now, only the pimaster can use this community. Do not
forget to delete the former community.

### Secure the communication between the webUI and the agents
To authenticate communications from the piseduce_webui, the piseduce_agents have to receive a token
in the POST data of the API calls. This token is a string of characters and it have to be changed to
avoid unwanted modifications of the agent configuration. The token of the agents is written in their
configuration file `config_agent.json`. To update it, we modify the value of the `auth_token`
property. Be careful, the value of this property is an array, for example, `[ "token1", "token2" ]`.
After changing the configuration file, the *agent_api* service must be restarted.

Now, we have to update the token in the webui. Go to the agent page by clicking on the *(admin)
Agent* item of the menu. Note the configuration of the agent and, then, delete the agent by clicking
on the yellow button of the *Existing Agents* section. Use the fields of the *Add Agent* section to
add the agent with the new token.

### Secure the admin login
By default, one admin user is created to log into the resource manager. As this user has the
administration rights, it is important to secure it. This default user log into the resource manager
with the login `admin@piseduce.fr` and the password `piseduceadmin`.

The best way to secure this account is to give the administration rights to another user. Then,
delete the `admin@piseduce.fr` user. These operations can be done from the user page described in
this [article](/2021-07-21-user-management/).

Another acceptable way is to set a complex password to the `admin@piseduce.fr` user. To change this
password, we log into the resource manager with the `admin@piseduce.fr` user. Then, we go to the
settings page by clicking and the *Settings* item of the menu. We open the *PiSeduce Credentials*
tab and fill the both fields with the same complex password. We complete the operation by clicking
on the *Update Password* button.