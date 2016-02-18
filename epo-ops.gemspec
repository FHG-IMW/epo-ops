# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'epo/ops/version'

Gem::Specification.new do |spec|
  spec.name          = 'epo-ops'
  spec.version       = Epo::Ops::VERSION
  spec.authors       = ['Max Kießling', 'Robert Terbach', 'Michael Prilop']

  spec.summary       = 'Query the European Patent Office API'
  spec.description   = 'This gem allows simple access to the European Patent'\
    ' Offices (EPO) Open Patent Services (OPS) using their XML-API'
  spec.homepage      = 'https://github.com/FHG-IMW/epo-ops'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'

  spec.add_dependency 'oauth2'
end
