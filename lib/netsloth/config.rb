require 'yaml'

module Netsloth
  class Config
    attr :data
    def method_missing(method, *args)
      if @data.nil?
        puts "No config loaded"
        exit 1
      end
      method = method.to_s
      if @data[method].nil?
        if args.any?
          return args.first
        else
          raise ArgumentError, "No such configuration variable #{method}"
        end
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
