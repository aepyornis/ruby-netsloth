require 'influxdb-client'

require_relative 'netsloth/version'
require_relative 'netsloth/config'
require_relative 'netsloth/shell_utils'
require_relative 'netsloth/app'
require_relative 'netsloth/measurement'
require_relative 'netsloth/measurement/iperf3'
require_relative 'netsloth/measurement/mifi'
require_relative 'netsloth/measurement/netflix'
require_relative 'netsloth/measurement/ooni'

# Gather network stats and upload the results to Influxdb
module Netsloth
end
