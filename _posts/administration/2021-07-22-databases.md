---
layout: post
title: Database Management
subtitle: Tables description and DB backups
category: Administration
index: 10
---
The configuration of the resource manager is stored to SQLite databases. SQLite databases are stored
in regular files which can be read from the `sqlite3` command. To backup databases, we just have to
copy the file associated to the database.

The piseduce_webui project uses the database `test-ui.db` at the root of the piseduce_webui
directory. The name can be changed in the configuration file `config_webui.json`. This database has
two tables:
* the *agent* table that stores the agents linked to the webui.
* the *user* table that stores the user accounts.

The piseduce_agent project uses the database `test-agent.db` at the root of the piseduce_agent
directory. The name can be changed in the configuration file `config_agent.json`. This database has
eight tables:
* the *action* table that stores the ongoing actions used in the deployment process. One action per
  Raspberry to deploy is created.
* the *action_prop* table that stores the properties of the actions, for example, the operating
  system passwords of Raspberrys.
* the *schedule* table that stores the list of the ongoing reservations with their start date and
  their end date.
* the *iot_nodes* table that stores the Iot-Lab sensors currently deployed.
* the *iot_selection* table that stores IoT-Lab filter before executing the reservation to the
  IoT-Lab plateform.
* the *rasp_environment* table that stores the Raspberry environments ready to be deployed on
  Raspberrys.
* the *rasp_node* table that stores the properties of the Raspberrys, for example, the model of the
  Raspberry.
* the *rasp_switch* table that stores the switches used to manage the Raspberry power supply.

For more details about the database tables, you can download the following
[pdf](/img/02_DB_tables.pdf).

The description of the tables is available by reading the database with the `sqlite3` tool and by
reading the Python code.

To read the schema of tables from the `sqlite3` tool, you need to log in to the pimaster:
```
cd piseduce_webui
sqlite3 test-ui.db
# List the tables
.tables
# Read the schema of the user table
.schema user
```

From the sources, the description of the database tables is in the `database/tables.py` file of each
project directory. The sources are also available from GitHub:
* [tables.py](https://github.com/remyimt/piseduce_webui/blob/master/database/tables.py){:target="_blank"}
  of the piseduce_webui project.
* [tables.py](https://github.com/remyimt/piseduce_agent/blob/master/database/tables.py){:target="_blank"}
  of the piseduce_agent project.

To create the databases of both the piseduce_webui project and the piseduce_agent project, the
existing databases have to be moved to another directory and the `init_database.py` script have to
be executed as follows:
* for the piseduce_webui project,
  ```
  python3 init_database.py
  ```
* for the piseduce_agent project,
  ```
  python3 init_database.py config_agent.json
  ```
  The new agent database has the `admin@piseduce.fr` user in this user table. The password of this
  user is `piseduceadmin`.

The configuration file of the piseduce_agent is required as parameter of every agent script in order
to run several agents on the same machine but on different ports (in this case, several
configuration files are used).