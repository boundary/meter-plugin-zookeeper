Boundary Zookeeper Plugin
-----------------------------
Collects metrics from Zookeeper server.

## Prerequisites

### Supported OS Platforms

|     OS    | Linux | Windows | SmartOS | OS X |
|:----------|:-----:|:-------:|:-------:|:----:|
| Supported |   v   |         |         |      |

#### Boundary Meter Versions V4.0 Or Greater

To get the new meter:

    curl -fsS \
        -d "{\"token\":\"<your API token here>\"}" \
        -H "Content-Type: application/json" \
        "https://meter.boundary.com/setup_meter" > setup_meter.sh
    chmod +x setup_meter.sh
    ./setup_meter.sh

#### For Boundary Meter less than V4.0

|  Runtime | node.js | Python | Java |
|:---------|:-------:|:------:|:----:|
| Required |         |    v   |      |

- [How to install Python?](https://help.boundary.com/hc/articles/202270132)
- Zookeeper 3.4+

### Plugin Configuration

In order the plugin to collect statistics from Zookeeper server, it needs access to the service stats API endpoint.

|Field Name     |Description                                         |
|:--------------|:---------------------------------------------------|
|service_port   |Zookeeper service port -          default: 2185     |
|service_host   |Zookeeper service host -          default: localhost|
|service_timeout|Zookeeper service connection timeout -    default: 1|
|pollInterval   |How often to query the Zookeeper service for metrics|

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

### References
Collects metrics from Zookeeper server using the mntr command. Take a look at Zookeeper Administrator's Guide for details (http://zookeeper.apache.org/doc/trunk/zookeeperAdmin.html)
