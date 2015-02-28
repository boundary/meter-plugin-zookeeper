from __future__ import (absolute_import, division, print_function, unicode_literals)
import logging
import time
import sys
import socket
from StringIO import StringIO

import boundary_plugin
import boundary_accumulator

"""
If getting statistics fails, we will retry up to this number of times before
giving up and aborting the plugin.  Use 0 for unlimited retries.
"""
PLUGIN_RETRY_COUNT = 0
"""
If getting statistics fails, we will wait this long (in seconds) before retrying.
"""
PLUGIN_RETRY_DELAY = 5

"""
Use the default port if the setting is missing in the config file
"""
DEFAULT_PORT = 2185

"""
Use the default host if the setting is missing in the config file
"""
DEFAULT_HOST = 'localhost'

"""
Default timeout vale
"""
DEFAULT_TIMEOUT = 1

"""
List of possible values
"""
METRICS = (
	("ZK_WATCH_COUNT", False),
	("ZK_NUM_ALIVE_CONNECTIONS", False),
	("ZK_OPEN_FILE_DESCRIPTOR_COUNT", False),
	("ZK_SERVER_STATE", False),
	("ZK_PACKETS_SENT", True),
	("ZK_PACKETS_RECEIVED", True),
	("ZK_MIN_LATENCY", False),
	("ZK_EPHEMERALS_COUNT", False),
	("ZK_ZNODE_COUNT", False),
	("ZK_MAX_FILE_DESCRIPTOR_COUNT", False)
)

class ZookeeperPlugin(object):
    def __init__(self, boundary_metric_prefix):
        self.boundary_metric_prefix = boundary_metric_prefix
        self.settings = boundary_plugin.parse_params()
        self.accumulator = boundary_accumulator
	
	service_port = self.settings.get("service_port", DEFAULT_PORT)
	service_host = self.settings.get("service_host", DEFAULT_HOST)
	
	self._address = (service_host, int(service_port))
	self._timeout = self.settings.get("service_timeout", DEFAULT_TIMEOUT)

    def _create_socket(self):
	return socket.socket()

    def _send_cmd(self, cmd):
	""" Send a 4letter word command to the server """
	s = self._create_socket()
	s.settimeout(self._timeout)
	s.connect(self._address)
	s.send(cmd)
	data = s.recv(2048)
	s.close()
	return data

    def _parse(self, data):
	""" Parse the output from the 'mntr' 4letter word command """
	h = StringIO(data)
	result = {}
	for line in h.readlines():
	    try:
	        key, value = self._parse_line(line)
	        result[key] = value
	    except ValueError:
	        pass # ignore broken lines
	return result

    def _parse_line(self, line):
	try:
	    line = line.split('\t')
	    return line[0], line[1]
	    
	except ValueError:
	    raise ValueError('Found invalid line: %s' % line)


    def get_stats(self):
	""" Get ZooKeeper server stats as a map """
	data = self._send_cmd('mntr')
	if data:
	    return self._parse(data)
	else:
	    data = self._send_cmd('stat')

	return self._parse_stat(data)

    def get_stats_with_retries(self, *args, **kwargs):
        """
        Calls the get_stats function, taking into account retry configuration.
        """
        retry_range = xrange(PLUGIN_RETRY_COUNT) if PLUGIN_RETRY_COUNT > 0 else iter(int, 1)
        for _ in retry_range:
            try:
                return self.get_stats(*args, **kwargs)
            except Exception as e:
                logging.error("Error retrieving data: %s" % e)
                time.sleep(PLUGIN_RETRY_DELAY)

        logging.fatal("Max retries exceeded retrieving data")
        raise Exception("Max retries exceeded retrieving data")

    def handle_metrics(self, data):
	for boundary_name, accumulate in METRICS:
	    metric_name = boundary_name.lower()
            try:
		value = data[boundary_name.lower()].strip()
            except KeyError:
                value = None

            if not value:
                continue

            if accumulate:
                value = self.accumulator.accumulate(metric_name, int(value) )

            boundary_plugin.boundary_report_metric(self.boundary_metric_prefix + boundary_name, value)

    def main(self):
        logging.basicConfig(level=logging.ERROR, filename=self.settings.get('log_file', None))
        reports_log = self.settings.get('report_log_file', None)
        if reports_log:
            boundary_plugin.log_metrics_to_file(reports_log)

        boundary_plugin.start_keepalive_subprocess()

        while True:
            data = self.get_stats_with_retries()
            self.handle_metrics(data)
            boundary_plugin.sleep_interval()


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == '-v':
        logging.basicConfig(level=logging.INFO)

    plugin = ZookeeperPlugin('')
    plugin.main()
