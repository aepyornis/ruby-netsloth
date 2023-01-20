module Netsloth
  class App
    CONFIG = File.expand_path('../../../config/config.yml', __FILE__)
    include ShellUtils

    def main
      while true
        conf.measurements.each do |measurement|
          handler = Netsloth::Measurement.const_get(measurement.capitalize).new(self)
          handler.setup
          puts "GATHER #{measurement}"
          handler.gather_data
          puts "SUBMIT #{measurement}"
          handler.submit_data
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

    def conf
      @conf ||= Netsloth::Config.new(CONFIG)
    end

    def client
      @db_client ||= InfluxDB2::Client.new(
        conf.influxdb_host, conf.influxdb_token,
        precision: InfluxDB2::WritePrecision::SECOND,
        use_ssl: conf.influxdb_token.include?('https://'),
        bucket: conf.bucket,
        org: conf.org
      )
    end

    def writer
      @db_write_api ||= client.create_write_api
    end
  end
end
