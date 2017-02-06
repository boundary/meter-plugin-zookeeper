-- Copyright 2015 BMC Software, Inc.
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
local ipack = framework.util.ipack

local params = framework.params

local ds = NetDataSource:new(params.host, params.port, true)
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

local acc = Accumulator:new() 

function plugin:onParseValues(data)
  local parsed = parse(data)
  local result = {}
  local metric = function (...) ipack(result, ...) end
  local src = notEmpty(params.source,nil)
  metric('ZK_WATCH_COUNT',parsed.zk_watch_count,nil,src)
  metric('ZK_NUM_ALIVE_CONNECTIONS',parsed.zk_num_alive_connections,nil,src)
  metric('ZK_OPEN_FILE_DESCRIPTOR_COUNT',parsed.zk_open_file_descriptor_count,nil,src)
  metric('ZK_OUTSTANDING_REQUESTS',parsed.zk_outstanding_requests,nil,src)
  metric('ZK_PACKETS_SENT',parsed.zk_packets_sent,nil,src)
  metric('ZK_PACKETS_RECEIVED',parsed.zk_packets_received,nil,src)
  metric('ZK_APPROXIMATE_DATA_SIZE',parsed.zk_approximate_data_size,nil,src)
  metric('ZK_MIN_LATENCY',parsed.zk_min_latency,nil,src)
  metric('ZK_MAX_LATENCY',parsed.zk_max_latency,nil,src)
  metric('ZK_AVG_LATENCY',parsed.zk_avg_latency,nil,src)
  metric('ZK_EPHEMERALS_COUNT',parsed.zk_ephemerals_count,nil,src)
  metric('ZK_ZNODE_COUNT',parsed.zk_znode_count,nil,src)
  metric('ZK_MAX_FILE_DESCRIPTOR_COUNT',parsed.zk_max_file_descriptor_count,nil,src)
  if parsed.zk_server_state == "leader" then
    metric('ZK_SERVER_STATE',1,nil,src)
  else
    metric('ZK_SERVER_STATE',0,nil,src)
  end
  metric('ZK_FOLLOWERS',(parsed.zk_followers or 0),nil,src)
  metric('ZK_SYNCED_FOLLOWERS',(parsed.zk_synced_followers or 0),nil,src)
  metric('ZK_PENDING_SYNCS',(parsed.zk_pending_syncs or 0),nil,src)

 return result
end

plugin:run()

