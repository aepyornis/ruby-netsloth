module Netsloth
  class Measurement::Fast < Measurement
    def setup
      app.ensure_command(conf.fast_cmd)
    end

    def gather_data
      json = []
      app.run(conf.fast_cmd, '--json', verbose: true) do |line|
        json << line
      end
      data = JSON.parse(json.join("\n"))
      data["download_mbps"] = data["downloadSpeed"]
      data.delete("downloadSpeed")
      @data = data
    end
  end
end
