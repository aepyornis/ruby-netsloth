require 'tempfile'

module Netsloth
  class Measurement
    module Ooni
      # Ooni measurement interface
      class Measurement < Netsloth::Measurement
        class << self
          attr_accessor :command
        end

        def setup
          app.ensure_command(conf.ooni_cmd)
        end

        def gather_data
          Tempfile.create do |f|
            app.run(conf.ooni_cmd, self.class.command, '--yes', '--reportfile', f.path)
            @data = parse_ooni(JSON.parse(f.read))
            print_result
          end
        end

        # modify ooni json output
        def parse_ooni(json)
          json
        end

        def print_result
          puts "RESULT #{self.class.display_name} #{@data.to_json}"
        end
      end
    end
  end
end

require_relative 'ooni/dash'
require_relative 'ooni/ndt'
require_relative 'ooni/tor'
require_relative 'ooni/riseupvpn'
