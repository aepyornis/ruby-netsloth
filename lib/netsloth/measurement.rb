module Netsloth
  class Measurement
    # @return [Netsloth::App] app instance
    attr_reader :app
    # @return [Hash] measurement data submitted to influxdb
    attr_reader :data

    def initialize(app, options = {})
      @app = app
      @options = options
    end

    def conf
      @app.conf
    end

    # implement this and set @data with the results
    def gather_data
      raise NotImplementedError
    end

    # an optional method that will run before #gather_data
    def setup
    end

    def format_data
      {
        name: self.class.display_name,
        tags: { location: conf.location, user: conf.user, device: conf.device },
        fields: convert_int_to_float(@data),
        time: Time.now.to_i
      }
    end

    # ensures that all the number types are floats, since with InfluxDB you cannot
    # first submit an integer and then later submit a float.
    # There is probably a better way where we can first submit a schema.
    def convert_int_to_float(hsh)
      hsh.each do |key, value|
        if value.is_a? Integer
          hsh[key] = value.to_f
        elsif value.is_a? Hash
          ensure_float(hsh[key])
        end
      end
      hsh
    end

    def bps_to_mbps(bps)
      (bps / 1_000_000.0).round(4)
    end

    def kbps_to_mbps(kbps)
      (kbps / 1_000.0).round(4)
    end

    def submit_data
      return unless @data && @data.any?

      app.writer.write(data: format_data)
    end

    def self.display_name
      name.sub('Netsloth::Measurement::', '')
    end
  end
end
