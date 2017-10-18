# frozen_string_literal: true

module Riddle
  class Configuration
    class RealtimeIndex < Riddle::Configuration::Section
      include Riddle::Configuration::IndexSettings

      def self.settings
        Riddle::Configuration::IndexSettings.settings + [
          :rt_mem_limit, :rt_field, :rt_attr_uint, :rt_attr_bigint,
          :rt_attr_float, :rt_attr_timestamp, :rt_attr_string, :rt_attr_multi,
          :rt_attr_multi_64, :rt_attr_bool, :rt_attr_json
        ]
      end

      attr_accessor :rt_mem_limit, :rt_field, :rt_attr_uint, :rt_attr_bigint,
        :rt_attr_float, :rt_attr_timestamp, :rt_attr_string, :rt_attr_multi,
        :rt_attr_multi_64, :rt_attr_bool, :rt_attr_json

      def initialize(name)
        @name               = name
        @rt_field           = []
        @rt_attr_uint       = []
        @rt_attr_bigint     = []
        @rt_attr_float      = []
        @rt_attr_timestamp  = []
        @rt_attr_string     = []
        @rt_attr_multi      = []
        @rt_attr_multi_64   = []
        @rt_attr_bool       = []
        @rt_attr_json       = []

        initialize_settings
      end

      def type
        "rt"
      end

      def valid?
        !(@name.nil? || @path.nil?)
      end

      def render
        raise ConfigurationError unless valid?

        (
          ["index #{name}", "{"] +
          settings_body +
          ["}", ""]
        ).join("\n")
      end
    end
  end
end
