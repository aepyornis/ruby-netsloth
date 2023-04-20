# temporary for now, until not_so_fast is in rubygems:
require 'bundler/setup'
require 'not_so_fast'

module Netsloth
  class Measurement::Netflix < Measurement
    def setup
    end

    def gather_data
      attempts_left = 5
      while attempts_left > 0
        speed = NotSoFast.run(conf.netflix_run_seconds)
        if speed == 0
          puts "FAIL could not contact fast.com, trying #{attempts_left} more times."
          sleep 10
          attempts_left -= 1
          next
        else
          mbps = bps_to_mbps(speed)
          puts "RESULT #{self.class.display_name} #{mbps} mbps"
          @data = {"download_mbps" => mbps}
          return
        end
      end
      puts "GIVING UP"
    end
  end
end
