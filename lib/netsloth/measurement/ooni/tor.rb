module Netsloth
  class Measurement
    module Ooni
      # https://ooni.org/nettest/tor/
      class Tor < Measurement
        @command = "tor"

        def parse_ooni(json)
          json
        end
      end
    end
  end
end
