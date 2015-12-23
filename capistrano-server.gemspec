# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/server/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-server"
  spec.version       = Capistrano::Server::VERSION
  spec.authors       = ["khcr"]
  spec.email         = ["kocher.ke@gmail.com"]

  spec.summary       = "Capistrano tasks & files to help server deployment with nginx & puma."
  spec.description   = "Capistrano tasks & files to help server deployment with nginx & puma."
  spec.homepage      = "www.github.com/JS-Tech/capistrano-server"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  gem.add_dependency 'capistrano', '~> 3.1'
end
