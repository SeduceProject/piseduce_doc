---
layout: post
title: How to Use of the Resource Manager
subtitle: Deploy environments on Raspberry Pi
category: User Guide
index: 0
---

To access to the resource manager, users must create an account. After signing in, the reserve page of the resource
manager comes up. This page allows users to select the Raspberrys from their properties (model, SD card size, etc.) and
specify the start date and the duration of their reservation. After reserving Raspberrys, users have to configure the
environment to deploy on their nodes. Then, the manage page allows users to follow the progress of the deployments and
execute operations on their Raspberrys.

[![alt Resource Manager Reserve Page](/img/reserve_page.png# bordered)](/img/reserve_page.png){:target="_blank"}

The reserve page is divided into four sections: the list of nodes (1), the current filters (2), the selected nodes (3)
and the reservation times (4). The first section (1) shows Raspberrys that are currently managed by the manager. The
blue squares indicate the current time. The yellow squares show the periods where Raspberrys are available and the red
squares are for the periods where the Raspberrys are already reserved by the current user or another user.

To reserve Raspberrys from their properties, for example, to reserve Raspberry Pi 4, users add filters by specifying a
property name and the associated property value (2). The list of the properties can be viewed by double-clicking inside
the property name field. When the filter is added, the list of Raspberrys (1) is updated. To delete a filter, users have
to click on the green square at the right of the filter square.

To select Raspberrys, users can choose the number of required nodes at the bottom of the first part (1) or they can
select one specific Raspberry by clicking on its name. The selected Raspberrys appear in the selected nodes section (3).

Once all required Raspberrys have been selected, users set the deployment date (4) by selecting the day and the hour of
the beginning of the deployment. The end date of the reservation is calculated from the duration in hours. The time
needed to deploy the environment is included in the reservation. So, for a one hour reservation, the first 10 minutes
are used to deploy the environment then users can connect to their Raspberrys for 50 minutes.

After setting the deployment date, users have to click to the deploy button to reserve their nodes before proceeding to
configure the Raspberry environments on the configure page.

[![alt Resource Manager Configure Page](/img/configure_page.png# bordered)](/img/reserve_page.png){:target="_blank"}

The configure page allows users to configure the environment of their nodes. To organize their reservations, a name is
used to group all nodes of the same reservation. This name have to be defined in the **node bin name** field.

The **environment** field allows users to choose the operating system to deploy on every node. The description of the
environments is displayed at the top of the page when the field is selected.

The **update_os** field is used to update the operating system during the deployment process. If users need to use an
up-to-date system, it is strongly recommended to update the operating system during the deployment. Indeed, boot files
have to be copied again in the TFTP directory after updating the operating system. When users update the operating
system on their own, the boot files can be updated on their local SDCARD. If the new boot files are not copied to the
TFTP directory of the resource manager, some kernel modules can be broken.

The default value of the **part_size** field, i.e., *whole*, is recommended for most of the deployments. This value
ensures that the partition of the operating system will be extended on the whole SDCARD. The other values allow to
reduce the partition size of the operating system partition.

The **os_password** field is used to set the password of the default user (pi, ubuntu or tc) of the operating system. If
this field is blank, the password will be generated. For the environments including a web service, the password is also
used to secure the access of this service.

The **form_ssh_key** field allows users to add a public SSH key to the deployed environment. This SSH key configures the
root access. If users configure the SSH key available from the settings page, the two SSH keys are added to the SSH
server.

To start the deployment, users click on the *Deploy* button. The progress of the deployment can be monitored from the
manage page.

[![alt Resource Manager Manage Page](/img/manage_page.png# bordered)](/img/manage_page.png){:target="_blank"}

The manage page displays the Raspberrys of the user. The colored dot indicates the deployment state of the Raspberry in
order to follow the deployment process. A click on the Raspberry name will open a panel with additional information
about the Raspberry. For example, the OS password will be added to this panel when it will be set. For environments that
embed a web service, a access link will appear at the end of the deployment.

At the bottom of this page, the **Node Reconfiguration** section allows users to execute the following reconfigurations:
* Hard Reboot: reboot the node by turning off and on. Do not hard reboot the node during the deployment process (unless
  the node is in the lost state)!
* Deploy Again: restart the deployment process from the beginning. The environment is copied in the SDCARD again so all
  data is erased.
* Destroy: destroy the reservation of the node.
* Extend: Extend the reservation. The duration of the reservation is multiply by 2 with a maximum of 7 days. If the
  duration of the reservation is 2 days, the extend reconfiguration set it to 4 days.
Before executing reconfigurations, users have to select the nodes to reconfigure by ticking the square at the right to
the node name.

Once the deployment is completed, user nodes should be in the deployed state. Users can then connect to their nodes with
SSH by using the password with the default user of the operating system or their SSH key. The default user of the
operating systems is : *pi* for raspbian environments, *tc* for tiny_core environments and *ubuntu* for ubuntu
environments.
