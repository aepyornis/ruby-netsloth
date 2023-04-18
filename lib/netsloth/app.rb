module Netsloth
  class App
    CONFIG = File.expand_path('../../../config/config.yml', __FILE__)
    HOME = File.expand_path('../../..', __FILE__)

    include ShellUtils

    attr_reader :conf, :handlers

    def initialize
      @conf = Netsloth::Config.new(CONFIG)
      @handlers = @conf.measurements.map do |measturement_name|
        Netsloth::Measurement.const_get(measturement_name.split('.').map(&:capitalize).join("::"))
      end
    end

    def main
      puts "ENV USER=#{conf.user} LOCATION=#{conf.location} DEVICE=#{conf.device} HOST=#{conf.influxdb_host}"
      @handlers.each do |c|
        puts "SETUP #{c.display_name}"
        c.new(self).setup
      end

      unless client.ping.status == "ok"
        puts "ERROR influxdb ping failed"
        exit 1
      end

      while true
        @handlers.each do |measurement_class|
          handler = measurement_class.new(self)
          puts "GATHER #{measurement_class.display_name}"
          handler.gather_data
          if @conf.debug
            puts "DATA #{measurement_class.display_name} (#{conf.user},#{conf.location},#{conf.device}) #{handler.data}"
          end
          puts "SUBMIT #{measurement_class.display_name}"
          handler.submit_data

          if @handlers.length > 1
            sleep conf.pause_between_measurements
          end
        end
        puts "SLEEP for #{conf.gather_interval_seconds} seconds"
        sleep conf.gather_interval_seconds
      end
      puts "DONE"
    end

    # be more graceful in the future...
    def quit
      puts "QUIT"
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
  end
end
