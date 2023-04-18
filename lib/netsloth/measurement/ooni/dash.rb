require 'tempfile'

module Netsloth
  class Measurement::Ooni::Dash < Measurement
    def setup
      app.ensure_command(conf.ooni_cmd)
    end

    def gather_data
      Tempfile.create do |f|
        app.run(conf.ooni_cmd, "dash","--yes", "--reportfile", f.path)
        @data = parse_results(JSON.parse(f.read))
        puts "RESULT #{self.class.display_name} #{@data["median_bitrate_mbps"]} mbps"
      end
    end

    private

    def parse_results(json)
      data = json
        .slice("software_name", "software_version", "report_id", "measurement_start_time", "probe_asn", "test_runtime")
        .merge('hostname' => json.dig("test_keys", "server", "hostname"))
        .merge(json.dig("test_keys", "simple")) # summary data
      data["median_bitrate_mbps"] = kbps_to_mbps(data["median_bitrate"])
      data.delete("median_bitrate")
      return data
    end
  end
end
