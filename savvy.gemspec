# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'savvy/version'

Gem::Specification.new do |spec|
  spec.name          = "savvy"
  spec.version       = Savvy::VERSION
  spec.authors       = ["Alexa Grey"]
  spec.email         = ["devel@mouse.vc"]

  spec.summary       = %q{ENV-backed configuration helper for Redis, Sidekiq, etc}
  spec.description   = %q{ENV-backed configuration helper for Redis, Sidekiq, etc}
  spec.homepage      = "https://github.com/scryptmouse/savvy"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "cleanroom", "~> 1.0"
  spec.add_dependency "commander"
  spec.add_dependency "dux", ">= 0.8.0", "< 2.0"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "stub_env"
  spec.add_development_dependency "pry"
end
