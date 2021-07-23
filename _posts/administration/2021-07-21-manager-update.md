---
layout: post
title: Updating the Resource Manager
subtitle: Get the sources and generate the DB
category: Administration
index: 9
---

The PiSeduce resource manager consists of two projects: the
[piseduce_webui](http://github.com/remyimt/piseduce_webui){:target="_blank"} and the
[piseduce_agent](http://github.com/remyimt/piseduce_agent){:target="_blank"}. These two projects are
available on Github, and so, they can be updated by running the `git pull` command.

Although these projects are independent, it is important to update the two projects at the same time
in order to avoid potential issues related to the modification of the agent API.

### Update the webUI
First, update the sources of the piseduce_webui project:
```
cd /root/piseduce_webui
git pull
```

If the `database/tables.py` file has been changed, we probably have to update the database table
schemas. We start by dumping the current database into a file:
```
sqlite3 test-ui.db .schema > schema.sql
sqlite3 test-ui.db .dump > dump.sql
grep -vx -f schema.sql dump.sql > data.sql
rm schema.sql dump.sql
```
Then, we move the current database to another directory and create the new database:
```
mv test-ui.db ..
python3 init_database.py
```
The new `test-ui.db` file is created. This database contains the default *admin@piseduce.fr* user
that we will delete. Then, we edit the `data.sql` file to update the insert queries according to the
new database schema. To complete the database update, we insert the data into the new database:
```
sqlite3 test-ui.db
delete from user;
.schema
.exit
# Update the insert queries according to the DB schema previously displayed
vim data.sql
sqlite3 test-ui.db < data.sql
```
The update is completed. Do not forget to remove the old database:
```
rm ../test-ui.db data.sql
```

### Update the agent
First, we save our configuration file in another directory and update the sources of the
piseduce_agent project. After, we can erase the default configuration with our customized one:
```
cd /root/piseduce_agent
mv config_agent.json ..
git pull
mv ../config_agent.json .
```
If the `database/tables.py` file has been changed, we probably have to update the database table
schema. We start by dumping the current database into a file:
```
sqlite3 test-agent.db .schema > schema.sql
sqlite3 test-agent.db .dump > dump.sql
grep -vx -f schema.sql dump.sql > data.sql
rm schema.sql dump.sql
```
Then, we move the current database to another directory and create the new database:
```
mv test-agent.db ..
python3 init_database.py config_agent.json
```
The new `test-agent.db` file is created. We edit the `data.sql` file to update the insert queries
according to the new database schema. To complete the database update, we insert the data into the
new database:
```
sqlite3 test-agent.db .schema
# Update the insert queries according to the DB schema previously displayed
vim data.sql
sqlite3 test-agent.db < data.sql
```
The update is completed. Do not forget to remove the old database:
```
rm ../test-agent.db data.sql
```

### Restart the PiSeduce services
To finish the update, we restart all the PiSeduce services:
```
service webui restart
service agent_api restart
service agent_exec restart
```
We check that all services are running to make sure everything is fine!
```
service webui status
service agent_api status
service agent_exec status
```
The log file of the webui is located at `/root/piseduce_webui/info_webui.log`. The log files of the
agent are located at `/root/piseduce_agent/info_api.log` and `/root/piseduce_agent/info_exec.log`.
Some log messages could appear in the system logs located at `/var/log/syslog`.