require 'net/http'

module Netsloth
  class Measurement::Mifi < Measurement
    ENDPOINT = "http://192.168.1.1/srv/status"

    def setup
      r = Net::HTTP.get_response(URI(ENDPOINT))
      unless r.is_a?(Net::HTTPSuccess) && r["Server"] == "MiFi"
        raise "Not connected to a MiFi hotspot"
      end
    end

    def gather_data
      @data = JSON.parse(Net::HTTP.get(URI(ENDPOINT)))['statusData']

      if @data.nil?
        puts "Error gathering data from mifi"
      end
    end
  end
end
