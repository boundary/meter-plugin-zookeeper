local framework = require('framework')
local split = framework.string.split
local notEmpty = framework.string.notEmpty

local Plugin = framework.Plugin
local NetDataSource = framework.NetDataSource
local Accumulator = framework.Accumulator
require('fun')(true) -- Shows a warn when overriding an existing function.

local params = framework.params
params.name = 'Boundary Zookeeper plugin'
params.version = '1.2'
params.tags = 'plugin,lua,zookeeper'

local zookeeperDataSource = NetDataSource:new(params.service_host, params.service_port)
function zookeeperDataSource:onFetch(socket)
  socket:write('mntr\n')
end

local zookeeperPlugin = Plugin:new(params, zookeeperDataSource)

function parseLine(line)
  local parts = split(line, '\t')

  return parts
end

function toMapReducer (acc, x)
  local k = x[1]
  local v = x[2]

  acc[k] = v

  return acc
end

function parse(data)
  local lines = {}
  table.foreach(split(data, '\n'), function(i, v) if notEmpty(v) then table.insert(lines, v) end end)
  local parsedLines = map(parseLine, lines)
  local m = reduce(toMapReducer, {}, parsedLines)

  return m
end

local accumulated = Accumulator:new() 
function zookeeperPlugin:onParseValues(data)
	
  local parsed = parse(data)

  local metrics = {}
	
  metrics['ZK_WATCH_COUNT'] = false
  metrics['ZK_NUM_ALIVE_CONNECTIONS'] = false
  metrics['ZK_OPEN_FILE_DESCRIPTOR_COUNT'] = false
  metrics['ZK_PACKETS_SENT'] =  true
  metrics['ZK_PACKETS_RECEIVED'] = true
  metrics['ZK_MIN_LATENCY'] = false
  metrics['ZK_EPHEMERALS_COUNT'] = false
  metrics['ZK_ZNODE_COUNT'] = false
  metrics['ZK_MAX_FILE_DESCRIPTOR_COUNT'] = false

  local result = {}
  each(
    function (boundaryName, acc) 
      local metricName = string.lower(boundaryName) 
      local value = tonumber(parsed[metricName])

      table.insert(result, framework.util.pack(boundaryName, acc and accumulated:accumulate(boundaryName, value) or value, nil, zookeeperPlugin.source))
    end, metrics)

  return result
end

zookeeperPlugin:run()
