require File.join File.expand_path('lib', __dir__), 'factorio_mods/version'

Gem::Specification.new do |spec|
  spec.name          = 'factorio_mods'
  spec.version       = FactorioMods::VERSION
  spec.authors       = ['Alexander Olofsson']
  spec.email         = ['ace@haxalot.com']

  spec.summary       = %q{Write a short summary, because RubyGems requires one.}
  spec.description   = %q{Write a longer description or delete this line.}
  spec.homepage      = 'https://github.com/ananace/ruby-factorio-mods'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'inifile', '~> 3.0'
  spec.add_dependency 'logging', '~> 2'
  spec.add_dependency 'nokogiri', '~> 1'
  spec.add_dependency 'rubyzip', '~> 1.2'
  spec.add_dependency 'thor'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
end
