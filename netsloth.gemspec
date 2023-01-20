# For more information and examples about making a new gem, check out our
# guide at: https://bundler.io/guides/creating_gem.html

require_relative "lib/netsloth/version"

Gem::Specification.new do |spec|
  spec.name = "netsloth"
  spec.version = Netsloth::VERSION
  spec.authors = ["calyx"]
  spec.email = ["root@calyx.org"]

  spec.summary = "Gather networks stats in InfluxDB"
  spec.description = "Gather networks stats in InfluxDB"
  spec.homepage = "https://0xacab.org/calyx"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://0xacab.org/calyx"
  spec.metadata["changelog_uri"] = "https://0xacab.org/calyx"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "influxdb-client", "~> 2.9.0"
end
