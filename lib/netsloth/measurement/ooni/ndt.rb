require 'tempfile'

module Netsloth
  class Measurement
    module Ooni
      # https://ooni.org/nettest/ndt/
      class Ndt < Measurement
        @command = "ndt"

        def parse_ooni(json)
          data = json
                   .slice("software_name", "software_version", "report_id", "measurement_start_time", "test_runtime", "probe_asn")
                   .merge('hostname' => json.dig("test_keys", "server", "hostname"))
                   .merge(json.dig("test_keys", "summary"))
          data["download_mbps"] = kbps_to_mbps(data["download"])
          data["upload_mbps"] = kbps_to_mbps(data["upload"])
          data.delete("download")
          data.delete("upload")
          data
        end

        def print_result
          puts "RESULT #{self.class.display_name} #{@data['download_mbps']} mbps down, #{@data['upload_mbps']} mbps up"
        end
      end
    end
  end
end
