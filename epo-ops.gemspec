# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'epo_ops/version'

Gem::Specification.new do |spec|
  spec.name          = 'epo-ops'
  spec.version       = EpoOps::VERSION
  spec.authors       = ['Max Kießling', 'Robert Terbach', 'Michael Prilop']

  spec.summary       = 'Ruby interface to the European Patent Office API (OPS)'
  spec.description   = 'This gem allows simple access to the European Patent'\
    ' Offices (EPO) Open Patent Services (OPS) using their XML-API'
  spec.homepage      = 'https://github.com/FHG-IMW/epo-ops'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 11'
  spec.add_development_dependency 'minitest', '~> 5.8'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'vcr', '~> 2.9'
  spec.add_development_dependency 'webmock', '~> 1.22'
  spec.add_development_dependency 'simplecov'

  spec.add_development_dependency 'redis'
  spec.add_development_dependency 'connection_pool'

  spec.add_dependency 'oauth2', '~> 1.1'
  spec.add_dependency 'httparty', '~> 0.13'
end
