module Netsloth
  # Runs all measurements configured
  # ENV variable overrides configuration file
  class App
    CONFIG = File.expand_path('../../config/config.yml', __dir__)
    HOME = File.expand_path('../..', __dir__)

    # @return [Netsloth::Config] global configuration
    attr_reader :conf

    # @return [Netsloth::Measurement] enabled measurements to run
    attr_reader :handlers

    # @param f [String] alternative to config.yml
    def initialize(f = nil)
      configfile = f || CONFIG
      puts "CONFIGFILE #{configfile}"
      @conf = Netsloth::Config.new(configfile)

      @handlers = @conf.measurements.map { |m| get_handler(m) }

      @handlers.each do |(measurement_class, options)|
        puts "SETUP #{measurement_class.display_name}"
        measurement_class.new(self, options).setup
      end

      unless client.ping.status == 'ok'
        puts 'ERROR influxdb ping failed'
        exit 1
      end
    end

    def run_once
      @handlers.each do |(measurement_class, options)|
        handler = measurement_class.new(self, options)
        handler.run
        sleep conf.pause_between_measurements if @handlers.length > 1 && conf.pause_between_measurements
      end
    end

    # a forever loop that runs each measurement in turn, waiting
    # conf.gather_interval_seconds between cycles
    #
    def main
      @sigint_received = false
      @sleep = false
      while true
        run_once
        if @sigint_received
          puts 'EXIT'
          exit
        end
        puts "SLEEP for #{conf.gather_interval_seconds} seconds"
        @sleep = true
        sleep conf.gather_interval_seconds
      end
    end

    # be more graceful in the future...
    def quit
      if @sleep
        exit
      else
        @sigint_received = true
        puts 'WAITING for measurement to finish'
      end
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
