# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'antex/version'

Gem::Specification.new do |spec|
  spec.name          = 'antex'
  spec.version       = Antex::VERSION
  spec.license       = 'MIT'

  spec.summary       = 'Universal TeX integrator'
  spec.description   = <<~DESCRIPTION.gsub(/\s+/, ' ')
    anTeX implements a universal TeX integration to easily embed
    and render arbitrary code using any engine and dialect.
  DESCRIPTION

  spec.author        = 'Paolo Brasolin'
  spec.email         = 'paolo.brasolin@gmail.com'
  spec.homepage      = 'https://github.com/paolobrasolin/antex'

  spec.files         = `git ls-files lib README.md LICENSE.txt`.split("\x0")
  spec.require_paths = ['lib']

  # spec.required_ruby_version = '~> 2.4'

  spec.add_runtime_dependency 'execjs'
  spec.add_runtime_dependency 'digest'
  spec.add_runtime_dependency 'nokogiri'
  spec.add_runtime_dependency 'liquid'

  # spec.add_development_dependency 'cucumber'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'yard'
end
