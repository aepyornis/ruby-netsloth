require 'tempfile'

module Netsloth
  class Measurement::Ooni::Ndt < Measurement
    def setup
      app.ensure_command(conf.ooni_cmd)
    end

    def gather_data
      Tempfile.create do |f|
        app.run(conf.ooni_cmd, "ndt","--yes", "--reportfile", f.path)
        @data = parse_results(JSON.parse(f.read))
      end
    end

    private

    def parse_results(json)
      json
        .slice("software_name", "software_version", "report_id", "measurement_start_time", "test_runtime", "probe_asn")
        .merge('hostname' => json.dig("test_keys", "server", "hostname"))
        .merge(json.dig("test_keys", "summary"))
    end
  end
end
