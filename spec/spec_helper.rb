require 'rubygems'
require 'bundler'

$:.unshift File.dirname(__FILE__) + '/../lib'
$:.unshift File.dirname(__FILE__) + '/..'

Bundler.require :default, :development

require 'riddle'
require 'sphinx_helper'

RSpec.configure do |config|
  sphinx = SphinxHelper.new
  sphinx.setup_mysql
  sphinx.generate_configuration
  sphinx.index
  
  config.before :all do
    `php -f spec/fixtures/data_generator.#{Riddle.loaded_version}.php`
    sphinx.start
  end
  
  config.after :all do
    sphinx.stop
  end
end

def query_contents(key)
  contents = open("spec/fixtures/data/#{key.to_s}.bin") { |f| f.read }
  contents.respond_to?(:encoding) ?
    contents.force_encoding('ASCII-8BIT') : contents
end
