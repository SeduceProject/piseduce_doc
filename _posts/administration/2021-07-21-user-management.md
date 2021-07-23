---
layout: post
title: User Management
subtitle: Enable/disable user accounts
category: Administration
index: 5
---
After installing the PiSeduce resource manager, administrators can log in with the user
*admin@piseduce.fr* and the password *piseduceadmin*. This password can also be used to connect via
SSH with the *pi* user. **Both accounts have to be secured by changing the default password**.

While connecting with the admin credentials, administrators can access to the administration pages
from the menu at the left. The *(admin) User* item allows administrators to manage the users.

[![alt User Page](/img/user_page.png# bordered)](/img/user_page.png){:target="_blank"}

From this page, administrators can see:
* In the *Pending User Requests* section, the users who are waiting for the validation of their
  account by administrators. Pending users can not log into the resource manager. The *Confirmed
  Email* column indicates whether or not the email has been verified. The *Authorize* button
  activates the user account that becomes an *Authorized User*. The *Remove* button deletes the
  user email from the database.
* In the *Authorized Users* section, the users who are authorized to log into the resource manager.
  Consequently, these users can reserve Raspberrys and deploy environments. The *Promote* button
  gives the administrator rights to the user that becomes an *Admin User*. The *Revoke* button
  disables the user account that becomes a *Pending User*.
* In the *Admin Users* section, the users who are administrator access. These users can see and use
  the administration pages. The *Revoke* button removes the administrator rights, and so, the user
  becomes an *Authorized User*.

The user page is the efficient way to manage the user accounts, give administrator privileges and
authorize users to log in.