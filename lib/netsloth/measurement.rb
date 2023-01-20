module Netsloth
  class Measurement
    attr :app
    def initialize(app)
      @app = app
    end

    def conf
      @app.conf
    end

    def setup
    end
  end
end