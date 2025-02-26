module Netsloth
  class Measurement
    module Ooni
      # https://ooni.org/nettest/riseupvpn/
      class Riseupvpn < Measurement
        @command = 'riseupvpn'

        def parse_ooni(json)
          json
            .slice('test_start_time', 'measurement_start_time', 'probe_asn', 'test_runtime')
            .merge({
                     'failure' => json.dig('test_keys', 'failure'),
                     'api_failures' => JSON.dump(json.dig('test_keys', 'api_failures')),
                     'tcp_connect' => JSON.dump(json.dig('test_keys', 'tcp_connect'))
                   })
        end

        def print_result
          puts "RESULT #{self.class.display_name} api_failures: #{JSON.parse(@data['api_failures']).length}"
        end
      end
    end
  end
end
