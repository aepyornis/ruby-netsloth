module Netsloth
  class Measurement::Iperf3 < Measurement
    def setup
      app.ensure_command(conf.iperf3_cmd)
    end

    def gather_data
      @data = {}
      upload = run_iperf(:upload)
      @data["upload_mbps"] = bps_to_mbps(upload["bits_per_second"] || 0.0)
      @data["upload_rtt"]  = upload["mean_rtt"] || 0.0
      download = run_iperf(:download)
      @data["download_mbps"] = bps_to_mbps(download["bits_per_second"] || 0.0)
      @data["download_rtt"]  = download["mean_rtt"] || 0.0
    end

    private

    def run_iperf(mode=:upload)
      flag = mode == :upload ? "" : "--reverse"
      options = [
        conf.iperf3_cmd,
        '--client', conf.iperf3_host,
        '--port', conf.iperf3_port,
        '--time', conf.iperf3_duration_seconds,
        '--json',
        flag
      ]
      json = []
      app.run(*options, verbose: true) do |line|
        unless line =~ /iperf3: error/
          json << line
        end
      end
      hash = JSON.parse(json.join("\n"))
      summary  = hash.dig("end", "streams")&.first
      if summary.nil?
        puts "ERROR: iperf3 returned no data"
        return {}
      end
      return summary["receiver"]
    rescue Exception => exc
      puts "ERROR: could not parse iperf3 JSON output (#{exc.to_s})"
      puts json.join("\n")
      return {}
    end

  end
end
