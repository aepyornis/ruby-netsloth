# For more information and examples about making a new gem, check out our
# guide at: https://bundler.io/guides/creating_gem.html

require_relative 'lib/netsloth/version'

Gem::Specification.new do |spec|
  spec.name = 'netsloth'
  spec.version = Netsloth::VERSION
  spec.authors = ['Calyx Institute']
  spec.email = ['petal@calyxinstitute.org']

  spec.summary = 'Gather networks stats in InfluxDB'
  spec.description = 'Gather networks stats in InfluxDB'
  spec.homepage = 'https://0xacab.org/calyx/gems/netsloth'
  spec.required_ruby_version = '>= 3.3.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://0xacab.org/calyx/gems/netsloth/-/commits/main'

  spec.files = Dir['config/*.yml', 'lib/**/*.rb'] + ['bin/netsloth', 'Gemfile', 'netsloth.gemspec', 'README.md']
  spec.bindir = 'bin'
  spec.executables = ['netsloth']
  spec.require_paths = ['lib']

  spec.add_dependency 'influxdb-client', '~> 3.2.0'
end
