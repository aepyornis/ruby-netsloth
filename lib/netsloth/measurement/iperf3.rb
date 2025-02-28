module Netsloth
  class Measurement::Iperf3 < Measurement
    def setup
      app.ensure_command(conf.iperf3_cmd)
    end

    def gather
      @data = {
        'iperf3_host' => @options.fetch('iperf3_host', conf.iperf3_host),
        'iperf3_duration_seconds' => @options.fetch('iperf3_duration_seconds', conf.iperf3_duration_seconds)
      }
      upload = run_iperf(:upload)
      @data['upload_mbps'] = bps_to_mbps(upload['bits_per_second'] || 0.0)
      @data['upload_rtt']  = upload['mean_rtt'] || 0.0
      download = run_iperf(:download)
      @data['download_mbps'] = bps_to_mbps(download['bits_per_second'] || 0.0)
      @data['download_rtt']  = download['mean_rtt'] || 0.0
      puts "RESULT iperf3[#{@options.fetch('iperf3_host',
                                           conf.iperf3_host)}]: #{@data['download_mbps']} mbps down, #{@data['upload_mbps']} mbps up"
    end

    private

    def run_iperf(mode = :upload)
      flag = mode == :upload ? '' : '--reverse'
      options = [
        conf.iperf3_cmd,
        '--client', @options.fetch('iperf3_host', conf.iperf3_host),
        '--port', @options.fetch('iperf3_port', conf.iperf3_port),
        '--time', @options.fetch('iperf3_duration_seconds', conf.iperf3_duration_seconds),
        '--json',
        flag
      ]
      json = []
      app.run(*options, verbose: app.conf.debug) do |line|
        json << line unless line =~ /iperf3: error/
      end
      hash = JSON.parse(json.join("\n"))
      summary = hash.dig('end', 'streams')&.first
      if summary.nil?
        puts 'ERROR: iperf3 returned no data'
        return {}
      end
      summary['receiver']
    rescue StandardError => e
      puts "ERROR: could not parse iperf3 JSON output (#{e})"
      puts json.join("\n")
      {}
    end
  end
end
