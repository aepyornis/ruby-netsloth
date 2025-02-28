require 'yaml'

module Netsloth
  INT_FIELDS = %w[GATHER_INTERVAL_SECONDS NETFLIX_RUN_SECONDS PAUSE_BETWEEN_MEASUREMENTS
                  IPERF3_DURATION_SECONDS].to_set.freeze

  class Config
    attr_reader :data

    def method_missing(method, *args)
      raise 'No config loaded' if @data.nil?

      method = method.to_s

      if @data.key?(method)
        @data[method]
      elsif args.any?
        args.first
      else
        raise ArgumentError, "No such configuration variable #{method}"
      end
    end

    def respond_to_missing?(name, include_private)
      @data.key?(name) || super
    end

    def initialize(path)
      unless File.exist?(path)
        puts "ERROR No such configuration file #{path}"
        exit 1
      end
      @data = YAML.load_file(path)

      # env variable override
      @data.keys.map(&:upcase).each do |k|
        next unless ENV[k] && ENV[k] != 'unknown'

        @data[k.downcase] = if INT_FIELDS.include?(k)
                              ENV[k].to_i
                            else
                              ENV[k]
                            end
      end

      unless allowed_devices.include?(device)
        puts "ERROR device not configured in allowed devices: #{allowed_devices.join(', ')}."
        exit 1
      end

      unless influxdb_token && influxdb_host && measurements && user && device && location && gather_interval_seconds
        puts 'ERROR invalid configuration'
        exit 1
      end

      puts "CONFIG user=#{user} location=#{location} device=#{device} influxdb_host=#{influxdb_host} gather_interval_seconds=#{gather_interval_seconds}"
    end
  end
end
