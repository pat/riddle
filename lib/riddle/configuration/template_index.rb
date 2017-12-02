# frozen_string_literal: true

module Riddle
  class Configuration
    class TemplateIndex < Riddle::Configuration::Section
      include Riddle::Configuration::IndexSettings

      def self.settings
        Riddle::Configuration::IndexSettings.settings
      end

      attr_accessor :parent

      def initialize(name)
        @name = name
        @type = 'template'

        initialize_settings
      end

      def render
        raise ConfigurationError, "#{@name} #{@parent}" unless valid?

        inherited_name = "#{name}"
        inherited_name << " : #{parent}" if parent
        (
          ["index #{inherited_name}", "{"] +
          settings_body +
          ["}", ""]
        ).join("\n")
      end

      def valid?
        @name
      end
    end
  end
end
