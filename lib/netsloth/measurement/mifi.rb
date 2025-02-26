require 'net/http'

module Netsloth
  class Measurement::Mifi < Measurement
    ENDPOINT = 'http://192.168.1.1/srv/status'

    def setup
      r = Net::HTTP.get_response(URI(ENDPOINT))
      return if r.is_a?(Net::HTTPSuccess) && r['Server'] == 'MiFi'

      raise 'Not connected to a MiFi hotspot'
    end

    def gather_data
      results = JSON.parse(Net::HTTP.get(URI(ENDPOINT)))['statusData']
      if results.nil?
        puts 'Error gathering data from mifi'
        nil
      else
        @data = parse_results(results)
      end
    end

    private

    INT_FIELDS = %w[statusBarBatteryPercent statusBarBytesReceived statusBarBytesTotal statusBarBytesTransmitted
                    statusBarClientListSize statusBarSignalBars]

    def parse_results(json)
      INT_FIELDS.each do |f|
        json[f] = json[f].to_i unless json[f].nil?
      end
      json
    end
  end
end
