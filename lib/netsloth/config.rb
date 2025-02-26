require 'yaml'

module Netsloth
  INT_FIELDS = %w[GATHER_INTERVAL_SECONDS NETFLIX_RUN_SECONDS PAUSE_BETWEEN_MEASUREMENTS
                  IPERF3_DURATION_SECONDS].to_set.freeze

  # Configuration. Value can be
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

    # Yaml configuration values
    def initialize(path)
      unless File.exist?(path)
        puts "No such configuration file #{path}"
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
    end
  end
end
