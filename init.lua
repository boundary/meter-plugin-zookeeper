-- Copyright 2015 Boundary, Inc.
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--    http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local framework = require('framework')
local split = framework.string.split
local notEmpty = framework.string.notEmpty
local Plugin = framework.Plugin
local NetDataSource = framework.NetDataSource
local Accumulator = framework.Accumulator
local map = framework.functional.map
local reduce = framework.functional.reduce
local filter = framework.functional.filter
local each = framework.functional.each
local pack = framework.util.pack

local params = framework.params

local ds = NetDataSource:new(params.service_host, params.service_port, true)
function ds:onFetch(socket)
  socket:write('mntr\n')
end

local plugin = Plugin:new(params, ds)

local function parseLine(line)
  return split(line, '\t')
end

local function toMapReducer (acc, x)
  local k = x[1]
  local v = x[2]
  acc[k] = v

  return acc
end

local function parse(data)
  local lines = filter(notEmpty, split(data, '\n'))
  local parsedLines = map(parseLine, lines)
  local m = reduce(toMapReducer, {}, parsedLines)

  return m
end

local accumulated = Accumulator:new() 

function plugin:onParseValues(data)
  p(data)
  local parsed = parse(data)

  local metrics = {}
	
  metrics['ZK_WATCH_COUNT'] = false
  metrics['ZK_NUM_ALIVE_CONNECTIONS'] = false
  metrics['ZK_OPEN_FILE_DESCRIPTOR_COUNT'] = false
  metrics['ZK_OUTSTANDING_REQUESTS'] = false
  metrics['ZK_PACKETS_SENT'] =  true
  metrics['ZK_PACKETS_RECEIVED'] = true
  metrics['ZK_APPROXIMATE_DATA_SIZE'] = true
  metrics['ZK_MIN_LATENCY'] = false
  metrics['ZK_MAX_LATENCY'] = false
  metrics['ZK_AVG_LATENCY'] = false
  metrics['ZK_EPHEMERALS_COUNT'] = false
  metrics['ZK_ZNODE_COUNT'] = false
  metrics['ZK_MAX_FILE_DESCRIPTOR_COUNT'] = false
  metrics['ZK_SERVER_STATE'] = false
  metrics['ZK_FOLLOWERS'] = false
  metrics['ZK_SYNCED_FOLLOWERS'] = false
  metrics['ZK_PENDING_SYNCS'] = false

  local result = {}
  each(
    function (boundary_name, acc) 
      local metric_name = boundary_name:lower()
      if parsed[metric_name] then
        local value = (metric_name == "zk_server_state" and (parsed[metric_name] == "leader" and 1 or 0)) or tonumber(parsed[metric_name])

        table.insert(result, pack(boundary_name, acc and accumulated:accumulate(boundary_name, value) or value))
      end
    end, metrics)

  return result
end

plugin:run()

