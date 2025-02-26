module Netsloth
  # Runs measurements configured by config/config.yml and env variables
  class App
    CONFIG = File.expand_path('../../config/config.yml', __dir__)
    HOME = File.expand_path('../..', __dir__)

    include ShellUtils

    attr_reader :conf, :handlers

    def initialize
      @conf = Netsloth::Config.new(CONFIG)

      @handlers = @conf.measurements.map(&method(:get_handler))

      unless @conf.allowed_devices.include?(@conf.device)
        puts "ERROR The `device` configuration must be one of #{@conf.allowed_devices.join(', ')}."
        exit 1
      end
    end

    # a forever loop that runs each measurement in turn, waiting
    # conf.gather_interval_seconds between cycles
    #
    def main
      puts "ENV USER=#{conf.user} LOCATION=#{conf.location} DEVICE=#{conf.device} HOST=#{conf.influxdb_host}"
      puts "CONFIG #{conf.data.to_json}"
      @handlers.each do |(measurement_class, options)|
        puts "SETUP #{measurement_class.display_name}"
        measurement_class.new(self, options).setup
      end

      unless client.ping.status == 'ok'
        puts 'ERROR influxdb ping failed'
        exit 1
      end

      while true
        @handlers.each do |(measurement_class, options)|
          handler = measurement_class.new(self, options)
          puts "GATHER #{measurement_class.display_name}" + (options.empty? ? '' : " #{options.inspect}")
          begin
            handler.gather_data
          rescue StandardError => e
            puts "SKIP #{measurement_class.display_name} because #{e.inspect}"
            puts "\t" + e.backtrace.join("\n\t")
          end
          if @conf.debug
            puts "DATA #{measurement_class.display_name} (#{conf.user},#{conf.location},#{conf.device}) #{handler.data}"
          end
          puts "SUBMIT #{measurement_class.display_name}"
          begin
            handler.submit_data
          rescue StandardError => e
            puts "SKIP #{measurement_class.display_name} because exception #{e}"
            puts '     ' + e.backtrace.join("    \n") if e.backtrace
          end
          sleep conf.pause_between_measurements if @handlers.length > 1
        end
        puts "SLEEP for #{conf.gather_interval_seconds} seconds"
        sleep conf.gather_interval_seconds
      end
      puts 'DONE'
    end

    # be more graceful in the future...
    def quit
      puts 'QUIT'
      exit
    end

    def client
      @db_client ||= InfluxDB2::Client.new(
        conf.influxdb_host, conf.influxdb_token,
        precision: InfluxDB2::WritePrecision::SECOND,
        use_ssl: conf.influxdb_host.start_with?('https://'),
        bucket: conf.bucket,
        org: conf.org
      )
    end

    def writer
      @db_write_api ||= client.create_write_api
    end

    private

    # Measurement constants are derived from their names
    #   ooni.dash becomes Netsloth::Measurement::Ooni::Dash
    #
    # They can also include a query string that will be passed as options to #new
    #   iperf3?foo=bar [Netsloth::Measurement::Iperf3, {'foo' => 'bar'}]
    #
    # @param m [String] measurement name
    # @return [Array<(Class, Hash)] measurement class and options
    def get_handler(m)
      options = if m.include?('?')
                  m.split('?').last.split('&').map { |pair| pair.split('=') }.to_h
                else
                  {}
                end

      klass = Netsloth::Measurement.const_get(m.split('?').first.split('.').map(&:capitalize).join('::'))

      [klass, options]
    end
  end
end
