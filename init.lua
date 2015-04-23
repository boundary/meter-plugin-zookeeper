local framework = require('framework.lua')
framework.table()
framework.util()
framework.functional()
local stringutil = framework.string

local Plugin = framework.Plugin
local NetDataSource = framework.NetDataSource
local Accumulator = framework.Accumulator
local net = require('net')
require('fun')(true) -- Shows a warn when overriding an existing function.

local params = framework.params
params.name = 'Boundary Zookeeper plugin'
params.version = '1.0'
params.tags = 'plugin,lua,zookeeper'

local zookeeperDataSource = NetDataSource:new(params.service_host, params.service_port)
function zookeeperDataSource:onFetch(socket)
  socket:write('mntr\n')
end

local zookeeperPlugin = Plugin:new(params, zookeeperDataSource)

function parseLine(line)
  local parts = stringutil.split(line, '\t')

  return parts
end

function toMapReducer (acc, x)
  local k = x[1]
  local v = x[2]

  acc[k] = v

  return acc
end

function parse(data)
  local lines = filter(stringutil.notEmpty, stringutil.split(data, '\n'))
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
      local metric = {}
      metric.metric = string.lower(boundaryName) 
      local value = tonumber(parsed[metricName])
      if acc then
        value = accumulated:accumulate(boundaryName, value)
      end

      metric.value = value
      table.insert(result, metric)
    end, metrics)

  return result
end

zookeeperPlugin:run()
