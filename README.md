# Boundary Zookeeper Plugin

Collects metrics from Zookeeper server.

### Prerequisites

#### Supported OS Platforms

|     OS    | Linux | Windows | SmartOS | OS X |
|:----------|:-----:|:-------:|:-------:|:----:|
| Supported |   v   |         |         |      |

#### Zookeeper 3.4+

The plugin relies on the command 'mntr' which is available only from zookeeper version 3.4 and above.

#### Boundary Meter versions v4.2 or later

- To install new meter go to Settings->Installation or [see instructions](https://help.boundary.com/hc/en-us/sections/200634331-Installation).
- To upgrade the meter to the latest version - [see instructions](https://help.boundary.com/hc/en-us/articles/201573102-Upgrading-the-Boundary-Meter).

### Plugin Setup

In order the plugin to collect statistics from Zookeeper server, it needs access to the service stats API endpoint.

### Plugin Configuration

|Field Name     |Description                                         |
|:--------------|:---------------------------------------------------|
| Host   |Zookeeper service host|
| Port   |Zookeeper service port|
| Timeout|Zookeeper service connection timeout|
| Poll Interval (ms) |How often to query the Zookeeper service for metrics|
| Source        |The Source to display in the legend for the zookeeper data.  It will default to the hostname of the server|

### Metrics Collected

|Metric Name                  |Description                                                              |
|:----------------------------|:------------------------------------------------------------------------|
|ZK_WATCH_COUNT               |Total amount of watches in zookeeper                                     |
|ZK_NUM_ALIVE_CONNECTIONS     |Number of active connections in Zookeeper                                |
|ZK_OPEN_FILE_DESCRIPTOR_COUNT|Total amount of file descriptors open in the system reported by zookeeper|
|ZK_PACKETS_SENT              |Total number of packages sent from Zookeeper                             |
|ZK_PACKETS_RECEIVED          |Total number of packages received in Zookeeper                           |
|ZK_MIN_LATENCY               |The minimum latency measured by Zookeeper                                |
|ZK_EPHEMERALS_COUNT          |The total amount of ephemerals in Zookeeper                              |
|ZK_ZNODE_COUNT               |Total number of data registers in Zookeeper                              |
|ZK_MAX_FILE_DESCRIPTOR_COUNT |Total maximum number of filedescriptors allowed to open                  |
|ZK_AVG_LATENCY               |The average latency measured by Zookeeper                                |
|ZK_MAX_LATENCY               |The maximum latency measured by Zookeeper                                |
|ZK_OUTSTANDING_REQUESTS      |Total number of requests waiting to be processed by Zookeeper            |
|ZK_SERVER_STATE              |Shows the server is currently a leader or a follower in the cluster      |
|ZK_APPROXIMATE_DATA_SIZE     |The approximate size of the data being handled by Zookeeper              |
|ZK_FOLLOWERS                 |The number of servers using this Zookeeper node as a leader              |
|ZK_SYNCED_FOLLOWERS          |Zookeeper server nodes which are synchronized with this leader           |
|ZK_PENDING_SYNCS             |Synchronization requests which are yet to be processed                   |


### Dashboards

- Zookeeper

### References
Collects metrics from Zookeeper server using the mntr command. Take a look at Zookeeper Administrator's Guide for details (http://zookeeper.apache.org/doc/trunk/zookeeperAdmin.html)
