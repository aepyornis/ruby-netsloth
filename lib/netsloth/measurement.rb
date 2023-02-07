module Netsloth
  class Measurement
    attr :app
    attr_reader :data
    def initialize(app)
      @app = app
    end

    def conf
      @app.conf
    end

    def setup
    end

    def format_data
      {
        name: self.class.name.split(":").last.downcase,
        tags: { location: conf.location, user: conf.user, device: conf.device },
        fields: @data,
        time: Time.now.to_i
      }
    end

    def submit_data
      if @data && @data.any?
        app.writer.write(data: format_data)
      end
    end
  end
end
