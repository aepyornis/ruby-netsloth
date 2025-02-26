require 'yaml'

module Netsloth
  INT_FIELDS = %w[GATHER_INTERVAL_SECONDS NETFLIX_RUN_SECONDS PAUSE_BETWEEN_MEASUREMENTS IPERF3_DURATION_SECONDS]

  class Config
    attr_reader :data

    def method_missing(method, *args)
      if @data.nil?
        puts 'No config loaded'
        exit 1
      end
      method = method.to_s
      if ENV[method.upcase] && ENV[method.upcase] != 'unknown'
        return ENV[method.upcase].to_i if INT_FIELDS.include?(method.upcase)

        ENV[method.upcase]

      elsif @data[method].nil?
        return args.first if args.any?

        raise ArgumentError, "No such configuration variable #{method}"

      elsif @data[method].is_a? String
        @data[method].sub('HOME', Netsloth::App::HOME)
      else
        @data[method]
      end
    end

    def initialize(path)
      unless File.exist?(path)
        puts "No such configuration file #{path}"
        exit 1
      end
      @data = YAML.load_file(path)
    end
  end
end
