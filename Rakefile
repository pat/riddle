# frozen_string_literal: true

require 'rubygems'
require 'bundler'

Bundler::GemHelper.install_tasks
Bundler.require :default, :development

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.rcov_opts = ['--exclude', 'spec', '--exclude', 'gems']
  spec.rcov      = true
end

YARD::Rake::YardocTask.new

task :default => :spec

task :fixtures do
  require './spec/spec_helper'
  BinaryFixtures.build_fixtures
end
