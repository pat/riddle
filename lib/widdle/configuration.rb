require 'widdle/configuration/section'

require 'widdle/configuration/distributed_index'
require 'widdle/configuration/index'
require 'widdle/configuration/indexer'
require 'widdle/configuration/realtime_index'
require 'widdle/configuration/remote_index'
require 'widdle/configuration/searchd'
require 'widdle/configuration/source'
require 'widdle/configuration/sql_source'
require 'widdle/configuration/xml_source'

module Riddle
  class Configuration
    class ConfigurationError < StandardError #:nodoc:
    end
    
    attr_reader :indexes, :searchd
    attr_accessor :indexer
    
    def initialize
      @indexer = Riddle::Configuration::Indexer.new
      @searchd = Riddle::Configuration::Searchd.new
      @indexes = []
    end
    
    def render
      (
        [@indexer.render, @searchd.render] +
        @indexes.collect { |index| index.render }
      ).join("\n")
    end
  end
end
