require 'net/http'

module Netsloth
  class Measurement
    class Mifi < Measurement
      ENDPOINT = 'http://192.168.1.1/srv/status'

      INT_FIELDS = %w[statusBarBatteryPercent statusBarBytesReceived statusBarBytesTotal statusBarBytesTransmitted
                    statusBarClientListSize statusBarSignalBars].freeze

      def setup
        r = Net::HTTP.get_response(URI(ENDPOINT))
        return if r.is_a?(Net::HTTPSuccess) && r['Server'] == 'MiFi'

        raise 'Not connected to a MiFi hotspot'
      end

      def gather
        @data = JSON.parse(Net::HTTP.get(URI(ENDPOINT)))['statusData']

        INT_FIELDS.each do |f|
          @data[f] = @data[f].to_i unless @data[f].nil?
        end

        puts "RESULT #{@data['statusBarTechnology']} #{@data['statusBarSignalBars']} bars"
      end
    end
  end
end
