# temporary for now, until not_so_fast is in rubygems:
require 'bundler/setup'
require 'not_so_fast'

module Netsloth
  class Measurement::Fast < Measurement
    def setup
    end

    def gather_data
      speed = NotSoFast.run(conf.fast_run_seconds)
      if speed != 0
        @data = {"download_mbps" => bps_to_mbps(speed)}
      end
    end
  end
end
