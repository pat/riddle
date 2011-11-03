require 'rubygems'
require 'bundler'

$:.unshift File.dirname(__FILE__) + '/../lib'
$:.unshift File.dirname(__FILE__) + '/..'

Dir['spec/support/**/*.rb'].each { |f| require f }

Bundler.require :default, :development

require 'riddle'

RSpec.configure do |config|
  config.include BinaryFixtures

  sphinx = Sphinx.new
  sphinx.setup_mysql
  sphinx.generate_configuration
  sphinx.index

  BinaryFixtures.build_fixtures Riddle.loaded_version

  config.before :all do |group|
    sphinx.start if group.class.metadata[:live]
  end

  config.after :all do |group|
    sphinx.stop if group.class.metadata[:live]
  end

  # enable filtering for examples
  config.filter_run :wip => true
  config.run_all_when_everything_filtered = true
end
