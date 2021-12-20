# frozen_string_literal: true

# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'riddle'
  s.version     = '2.4.3'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Pat Allan']
  s.email       = ['pat@freelancing-gods.com']
  s.homepage    = 'http://pat.github.io/riddle/'
  s.summary     = %q{An API for Sphinx, written in and for Ruby.}
  s.description = %q{A Ruby API and configuration helper for the Sphinx search service.}
  s.license     = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rake',   '>= 0.9.2'
  s.add_development_dependency 'rspec',  '>= 2.5.0'
  s.add_development_dependency 'yard',   '>= 0.7.2'
end
