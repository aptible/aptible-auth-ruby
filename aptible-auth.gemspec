# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'English'
require 'aptible/auth/version'

Gem::Specification.new do |spec|
  spec.name          = 'aptible-auth'
  spec.version       = Aptible::Auth::VERSION
  spec.authors       = ['Frank Macreery']
  spec.email         = ['frank@macreery.com']
  spec.description   = 'Ruby client for auth.aptible.com'
  spec.summary       = 'Ruby client for auth.aptible.com'
  spec.homepage      = 'https://github.com/aptible/aptible-auth'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($RS)
  spec.test_files    = spec.files.grep(/^spec\//)
  spec.require_paths = ['lib']

  spec.add_dependency 'aptible-resource', '>= 0.1.1'
  spec.add_dependency 'gem_config'
  spec.add_dependency 'oauth2-aptible'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'aptible-tasks', '>= 0.2.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 2.0'
  spec.add_development_dependency 'pry'
end
