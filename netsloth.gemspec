# For more information and examples about making a new gem, check out our
# guide at: https://bundler.io/guides/creating_gem.html

require_relative 'lib/netsloth/version'

Gem::Specification.new do |spec|
  spec.name = 'netsloth'
  spec.version = Netsloth::VERSION
  spec.authors = ['Calyx Institute']
  spec.email = ['petal@calyx.org']
  spec.licenses = ['MIT']

  spec.summary = 'Gather networks stats in InfluxDB'
  spec.description = 'Run network performance tests and store the results in InfluxDB'
  spec.homepage = 'https://github.com/aepyornis/ruby-netsloth'
  spec.required_ruby_version = '>= 3.4.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/aepyornis/ruby-netsloth/-/commits/main'

  spec.files = Dir['config/*.yml', 'lib/**/*.rb'] + ['bin/netsloth', 'Gemfile', 'netsloth.gemspec', 'README.md']
  spec.bindir = 'bin'
  spec.executables = ['netsloth']
  spec.require_paths = ['lib']

  spec.add_dependency 'base64'
  spec.add_dependency 'influxdb-client', '~> 3.2.0'
  spec.add_dependency 'logger'
  spec.add_dependency 'not_so_fast', '~> 0.1'
  spec.add_dependency 'rake', '~> 13.0'
end
