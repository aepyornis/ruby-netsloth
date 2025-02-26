module Netsloth
  class Measurement
    module Ooni
      # https://ooni.org/nettest/riseupvpn/
      class Riseupvpn < Measurement
        @command = "riseupvpn"

        def parse_ooni(json)
          json
        end
      end
    end
  end
end
