---
layout: post
title: Monitoring Raspberry Power Consumption
subtitle: Power Monitoring Agent Installation
category: Administration
index: 12
---

To provide power for the Raspberrys, we use the PoE technology of the switches.
Thanks to the PoE ports, we can easily turn off or turn on the Raspberrys from
SNMP commands sent to the switches. Another interesting feature is the power
monitoring of the PoE ports in order to know the power consumption of the
Raspberrys. In this article, we described the *agent_power* module of the
*piseduce_agent* project. This module enables to monitor the power consumption
of the PoE ports. Then, the monitoring data is available from the *Power
Monitoring* panel of the *piseduce_webui* project.

The *agent_power* module use a InfluxDB database. So, we must install
influxdb on the agent:
```
apt install influxdb influxdb-client
```
By default, the log messages of the influx database are written to the *syslog*
file. To write the influxDB log messages to another file, we edit the
`/etc/influxdb.conf`. We uncomment and edit the following line:
```
access-log-path = "/var/log/influxdb/access.log"
```
Then we restart the influxdb service:
```
service influxdb restart
```
The *agent_power* module sends SNMP commands to the switch in order to
retrieve the power consumption of the PoE ports. So, we have to know the OID to
retrieve these values (OID are dependent on the switch manufacturer). For our
switches, we have the following OIDs:

| Switch Manufacturer   |    OID of the power of the first port    |
| --------------------- | -----------------------------------------| 
| D-Link                | 1.3.6.1.4.1.171.11.153.1000.22.1.1.9.1.1 |
| Linksys               | 1.3.6.1.4.1.3955.1000.201.108.1.1.5.1.49 |
| --------------------- | -----------------------------------------| 

To test the OID, we can connect two or three Raspberrys to the switch. We verify
in the switch web interface that the PoE ports are turned on. Consequently, the
Raspberrys should be powered on. Then, we remove the last two numbers of the OID
and we use the resulting OID in the following command (with 192.0.0.4 as the
switch IP):
```
snmpwalk -v2c -c private 192.0.0.4 1.3.6.1.4.1.171.11.153.1000.22.1.1.9
>> iso.3.6.1.4.1.171.11.153.1000.22.1.1.9.1.1 = STRING: "0.0"
>> iso.3.6.1.4.1.171.11.153.1000.22.1.1.9.1.2 = STRING: "0.0"
>> iso.3.6.1.4.1.171.11.153.1000.22.1.1.9.1.3 = STRING: "0.0"
>> iso.3.6.1.4.1.171.11.153.1000.22.1.1.9.1.4 = STRING: "0.0"
>> iso.3.6.1.4.1.171.11.153.1000.22.1.1.9.1.5 = STRING: "0.0"
>> iso.3.6.1.4.1.171.11.153.1000.22.1.1.9.1.6 = STRING: "0.0"
>> iso.3.6.1.4.1.171.11.153.1000.22.1.1.9.1.7 = STRING: "0.0"
>> iso.3.6.1.4.1.171.11.153.1000.22.1.1.9.1.8 = STRING: "4.0"
>> iso.3.6.1.4.1.171.11.153.1000.22.1.1.9.1.9 = STRING: "0.0"
>> iso.3.6.1.4.1.171.11.153.1000.22.1.1.9.1.10 = STRING: "0.0"
>> iso.3.6.1.4.1.171.11.153.1000.22.1.1.9.1.11 = STRING: "0.0"
>> iso.3.6.1.4.1.171.11.153.1000.22.1.1.9.1.12 = STRING: "0.0"
```

The reply consists of one line per switch port. In the above example, we use a
12-port D-Link switch with one raspberry connected to the port 8.

The SNMP answers can be STRING (like in the above example) or INTEGER. In this
case, the integer value expressed the power as milliwatts as follows:
```
iso.3.6.1.4.1.3955.1000.201.108.1.1.5.1.49 = INTEGER: 0
iso.3.6.1.4.1.3955.1000.201.108.1.1.5.1.50 = INTEGER: 0
iso.3.6.1.4.1.3955.1000.201.108.1.1.5.1.51 = INTEGER: 0
iso.3.6.1.4.1.3955.1000.201.108.1.1.5.1.52 = INTEGER: 0
iso.3.6.1.4.1.3955.1000.201.108.1.1.5.1.53 = INTEGER: 0
iso.3.6.1.4.1.3955.1000.201.108.1.1.5.1.54 = INTEGER: 0
iso.3.6.1.4.1.3955.1000.201.108.1.1.5.1.55 = INTEGER: 0
iso.3.6.1.4.1.3955.1000.201.108.1.1.5.1.56 = INTEGER: 2700
```

In the above example, only one Raspberry is connected to the port 8. Its power
consumption is 2.7 W.

We have to fill the switch information with the right OID by updating the
information in the SQLite database or using the *Switch* panel of the
*piseduce_webui*.

To update the SQLite database, we have to remove the last number of the OID. So,
the OID of the Linksys switch is '1.3.6.1.4.1.3955.1000.201.108.1.1.5.1'. To
alter the SQLite database of the agent, we can use the following commands:
```
cd piseduce_agent
sqlite3 test-agent.db
.headers on
SELECT * FROM rasp_switch;
UPDATE rasp_switch SET power_oid = '1.3.6.1.4.1.3955.1000.201.108.1.1.5.1' WHERE name = 'RPI3_SW';
```

To fill out the switch information from the *Switch* panel, we have to note the
switch information in a notebook. Then, we delete the switch by clicking the
*Delete Switch* button (yellow button). Finally, we add the switch with the
previously noted information and the whole OID
*1.3.6.1.4.1.3955.1000.201.108.1.1.5.1.49* in the **power_oid** field.

To easily manage the *agent_power* module, we create a systemD service:
```
cp admin/agent_power.service /etc/systemd/system/
systemctl enable agent_power.service
service agent_power start
```

Now, the *agent_power* module writes to the influxDB database the power
consumption of all switch ports. We can check the database with the following
command:
```
influx -database monitoring -precision rfc3339
# Show all the values
SELECT * FROM power_W;
# Show the consumptions of the switch 'RPI3_SW' during the last 10 seconds
SELECT * FROM power_W WHERE time > now() - 10s  AND switch = 'RPI3_SW';
EXIT
```

The monitoring data is available from the *Power Monitoring* panel of the
*piseduce_webui* or from GET requests without authentication. The URL of the GET
requests is /user/powermonitoring/get/*agent_name*/*switch_name*/*period* where:
* **agent_name** is the name of the agent set in the *piseduce_webui* interface
* **switch_name** is the name of the switch set in the *piseduce_webui* interface
* **period** defines the time slot of the monitoring data. This string uses the
  influxDB syntax as follows:
  * **1d** is used to retrieve the monitoring data of the last day
  * **1h** is used to retrieve the monitoring data of the last hour 
  * **10s** is used to retrieve the monitoring data of the last ten seconds

In the following example, we send our request to the *piseduce_webui* with the
`wget` command. We retrieve the monitoring data of the switch *RPI4_SW* for the
last two hours. The *RPI4_SW* is managed by the *imt* agent:
```
wget http://192.0.0.6:9000/user/powermonitoring/get/imt/RPI4_SW/2h -O monitoring.json
```
With this command, the data is stored in the JSON file *monitoring.json*.

**IMPORTANT**: the GET requests are sent to the *piseduce_webui* not to the
*piseduce_agent*.
