# Boundary Zookeeper Plugin

Collects metrics from Zookeeper server.

### Prerequisites

#### Supported OS Platforms

|     OS    | Linux | Windows | SmartOS | OS X |
|:----------|:-----:|:-------:|:-------:|:----:|
| Supported |   v   |         |         |      |

#### Zookeeper 3.4+

#### Boundary Meter versions v4.2 or later

- To install new meter go to Settings->Installation or [see instructions](https://help.boundary.com/hc/en-us/sections/200634331-Installation).
- To upgrade the meter to the latest version - [see instructions](https://help.boundary.com/hc/en-us/articles/201573102-Upgrading-the-Boundary-Meter).

#### For Boundary Meter earlier than v4.2

|  Runtime | node.js | Python | Java |
|:---------|:-------:|:------:|:----:|
| Required |         |    v   |      |

- [How to install Python?](https://help.boundary.com/hc/articles/202270132)

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

### Dashboards

- Zookeeper

### References
Collects metrics from Zookeeper server using the mntr command. Take a look at Zookeeper Administrator's Guide for details (http://zookeeper.apache.org/doc/trunk/zookeeperAdmin.html)
