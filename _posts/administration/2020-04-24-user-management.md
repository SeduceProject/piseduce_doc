---
layout: post
title: User Management
subtitle: Manage User Access to the Resource Manager
category: Administration
index: 0
---
After installing the PiSeduce resource manager, administrators can log in with the user *admin@piseduce.fr* and the
password *piseduceadmin*. This password can also be used to connect via SSH with the *pi* user. **Both accounts must be
secured by changing the default password**.

While connecting with the admin credentials, administrators can access to the administration page from the blue button
at the top right corner of the home page. This page allows to set up the email configuration of the resource manager:

![alt Mail Configuration](/img/admin_mail_config.png# bordered)

The *Email&nbsp;Signup* feature allows users who have confirmed their email address to log in. If the SMTP server is
properly configured, a confirmation email is automatically sent to users after they sign up. So, if this feature is
enabled, administrators do not need to manually authorize users.

Below the *Email&nbsp;Signup* configuration, the fields allow administrators to configure the SMTP server used by the
resource manager. Do not forget to click on *Update&nbsp;Email&nbsp;Configuration* to update the configuration files.

After configuring the SMTP server, the *Send&nbsp;Confirmation&nbsp;Email* button allows administrators to send email to
users in order they can confirm their email address.

The email filters section allows administrators to define email domain names that can sign up to the resource manager.
If users with unauthorized email address try to sign up, administrators are NOT notified.

The beginning of the administration page is reserved to the user management:

![alt User Management](/img/admin_user_management.png# bordered)

From this page, administrators can see:
* In the *User Pending Requests* section, the users who are waiting for the validation of their account by
  administrators. The *Email* column indicates whether or not the email has been verified.
* In the *Authorized Users* section, the users who are authorized to log in the resource manager. These users can deploy
  environments with the resource manager.
* In the *Admin Users* section, the users who are administrator access. These users can use this administration page.

So, this page is the efficient way to manage the user accounts and give administrator privilege. Moreover, if the
*Email&nbsp;Signup* feature is disabled, administrator can easily add and delete user accounts of the resource manager.