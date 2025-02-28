module Netsloth
  # Run a network test and submit it to a remote influxdb database
  class Measurement
    # @return [Netsloth::App] app instance
    attr_reader :app
    # @return [Hash] measurement data
    attr_reader :data
    # @return [Hash] submission sent to influxdb
    attr_reader :submission

    def self.display_name
      name.sub('Netsloth::Measurement::', '')
    end

    # @param [Netsloth::App]
    # @param options [Hash]
    def initialize(app, options = {})
      @app = app
      @options = options
    end

    def conf
      @app.conf
    end

    def display_name
      "#{self.class.display_name} (#{@options.inspect}) (#{conf.user},#{conf.location},#{conf.device})"
    end

    # an optional method run once during setup
    def setup
    end

    def run
      begin
        puts "GATHER #{display_name}"
        gather
      rescue StandardError => e
        log_exc(e)
        puts "SKIP #{display_name}"
        return
      end

      puts "DATA #{@data.to_json}" if conf.debug

      begin
        puts "SUBMIT #{display_name}"
        submit
      rescue StandardError => e
        puts "SUBMIT ERROR #{display_name}"
        log_exc(e)
      end
    end

    # implement this and set @data with the results
    def gather
      raise NotImplementedError
    end

    # write to InfluxDB2::WriteApi
    def submit
      if @data.nil?
        puts 'SKIP NO DATA'
      else
        @submission = influxdb_submission
        freeze
        puts "WRITE #{@submission}" if conf.debug
        @app.writer.write(data: @submission)
      end
    end

    protected

    def influxdb_submission
      fields = @data.transform_values do |value|
        case value
        when Integer
          # store ints as floats in InfluxDB
          value.to_f
        when Hash
          value.to_json
        else
          value
        end
      end

      tags = {
        location: conf.location,
        user: conf.user,
        device: conf.device
      }

      { time: Time.now.to_f, name: self.class.display_name, tags:, fields: }
    end

    def bps_to_mbps(bps)
      (bps / 1_000_000.0).round(4)
    end

    def kbps_to_mbps(kbps)
      (kbps / 1_000.0).round(4)
    end

    def log_exc(exc)
      puts "ERROR: #{exc.inspect}"
      puts "\t" + exc.backtrace.join("\t\n") if exc.backtrace
    end
  end
end
