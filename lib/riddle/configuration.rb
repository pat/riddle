# frozen_string_literal: true

require 'riddle/configuration/section'
require 'riddle/configuration/index_settings'

require 'riddle/configuration/common'
require 'riddle/configuration/distributed_index'
require 'riddle/configuration/index'
require 'riddle/configuration/indexer'
require 'riddle/configuration/realtime_index'
require 'riddle/configuration/remote_index'
require 'riddle/configuration/searchd'
require 'riddle/configuration/source'
require 'riddle/configuration/sql_source'
require 'riddle/configuration/template_index'
require 'riddle/configuration/tsv_source'
require 'riddle/configuration/xml_source'

require 'riddle/configuration/parser'

module Riddle
  class Configuration
    class ConfigurationError < StandardError #:nodoc:
    end

    attr_reader :common, :indices, :searchd, :sources
    attr_accessor :indexer

    def self.parse!(input)
      Riddle::Configuration::Parser.new(input).parse!
    end

    def initialize
      @common  = Riddle::Configuration::Common.new
      @indexer = Riddle::Configuration::Indexer.new
      @searchd = Riddle::Configuration::Searchd.new
      @indices = []
      @sources = []
    end

    def render
      (
        [@common.render, @indexer.render, @searchd.render] +
        @sources.collect { |source| source.render } +
        @indices.collect { |index| index.render }
      ).join("\n")
    end
  end
end
