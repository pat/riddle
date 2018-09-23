# frozen_string_literal: true

module Riddle
  class Configuration
    class Index < Riddle::Configuration::Section
      include Riddle::Configuration::IndexSettings

      def self.settings
        Riddle::Configuration::IndexSettings.settings + [:source]
      end

      attr_accessor :parent, :sources

      def initialize(name, *sources)
        @name                     = name
        @sources                  = sources

        initialize_settings
      end

      def source
        @sources.collect { |s| s.name }
      end

      def render
        raise ConfigurationError, "#{@name} #{@sources.inspect} #{@path} #{@parent}" unless valid?

        inherited_name = parent ? "#{name} : #{parent}" : "#{name}"
        (
          @sources.collect { |s| s.render } +
          ["index #{inherited_name}", "{"] +
          settings_body +
          ["}", ""]
        ).join("\n")
      end

      def valid?
        (!@name.nil?) && (!( @sources.length == 0 || @path.nil? ) || !@parent.nil?)
      end
    end
  end
end
