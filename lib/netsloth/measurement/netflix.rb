# temporary for now, until not_so_fast is in rubygems:
require 'bundler/setup'
require 'not_so_fast'

module Netsloth
  class Measurement::Netflix < Measurement
    def setup
    end

    def gather_data
      speed = NotSoFast.run(conf.netflix_run_seconds)
      if speed != 0
        mbps = bps_to_mbps(speed)
        puts "RESULT #{self.class.display_name} #{mbps} mbps"
        @data = {"download_mbps" => mbps}
      end
    end
  end
end
