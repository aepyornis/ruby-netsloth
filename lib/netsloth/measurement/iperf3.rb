module Netsloth
  class Measurement::Iperf3 < Measurement
    def setup
      app.ensure_command(conf.iperf3_cmd)
    end

    def gather_data
      options = [
        conf.iperf3_cmd,
        '--client', conf.iperf3_host,
        '--port', conf.iperf3_port,
        '--time', conf.iperf3_duration_seconds,
        '--json',
      ]
      json = []
      app.run(*options, verbose: true) do |line|
        unless line =~ /iperf3: error/
          json << line
        end
      end
      @data = parse_results(json.join("\n"))
    end

    private

    def parse_results(json)
      hash = JSON.parse(json)
      summary  = hash.dig("end", "streams").first
      if summary.nil?
        puts "ERROR: iperf3 returned no data"
        return {}
      end
      sender   = summary["sender"]
      receiver = summary["receiver"]
      {
        "sender_bits_per_second"   => sender["bits_per_second"],
        "mean_rtt"                 => sender["mean_rtt"],
        "receiver_bits_per_second" => receiver["bits_per_second"]
      }
    rescue Exception => exc
      puts "ERROR: could not parse iperf3 JSON output (#{exc.to_s})"
      puts json.gsub("\n\n", "\n")
      return {}
    end
  end
end
