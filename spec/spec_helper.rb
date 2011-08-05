require 'rubygems'
require 'bundler'

$:.unshift File.dirname(__FILE__) + '/../lib'
$:.unshift File.dirname(__FILE__) + '/..'

Dir['spec/support/**/*.rb'].each {|f| require f}

Bundler.require :default, :development

require 'riddle'

RSpec.configure do |config|
  config.include BinaryReader
  
  sphinx = Sphinx.new
  sphinx.setup_mysql
  sphinx.generate_configuration
  sphinx.index
  
  `php -f spec/fixtures/data_generator.#{Riddle.loaded_version}.php`
  
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
