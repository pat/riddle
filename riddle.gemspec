# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'riddle/version'

Gem::Specification.new do |s|
  s.name        = 'riddle'
  s.version     = Riddle::Version
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Pat Allan']
  s.email       = ['pat@freelancing-gods.com']
  s.homepage    = 'http://pat.github.com/riddle/'
  s.summary     = %q{An API for Sphinx, written in and for Ruby.}
  s.description = %q{A Ruby API and configuration helper for the Sphinx search service.}

  s.rubyforge_project = 'riddle'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rake',   '>= 0.9.2'
  s.add_development_dependency 'rspec',  '>= 2.5.0'
  s.add_development_dependency 'yard',   '>= 0.7.2'
end
