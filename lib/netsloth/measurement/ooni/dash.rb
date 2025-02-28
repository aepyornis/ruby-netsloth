module Netsloth
  class Measurement
    module Ooni
      # https://ooni.org/nettest/dash/
      class Dash < Measurement
        @command = 'dash'

        def parse_ooni(json)
          data = json
                   .slice('software_name', 'software_version', 'report_id', 'measurement_start_time', 'probe_asn', 'test_runtime')
                   .merge('hostname' => json.dig('test_keys', 'server', 'hostname'))
                   .merge(json.dig('test_keys', 'simple')) # summary data
          data['median_bitrate_mbps'] = kbps_to_mbps(data['median_bitrate'])
          data['dash_median_bitrate'] = data.delete('median_bitrate')
          data
        end

        def print_result
          puts "RESULT #{self.class.display_name} #{@data['median_bitrate_mbps']} median_bitrate_mbps"
        end
      end
    end
  end
end
