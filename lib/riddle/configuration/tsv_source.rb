# frozen_string_literal: true

module Riddle
  class Configuration
    class TSVSource < Riddle::Configuration::Source
      def self.settings
        [:type, :tsvpipe_command, :tsvpipe_attr_field, :tsvpipe_attr_multi]
      end

      attr_accessor *self.settings

      def initialize(name, type = 'tsvpipe')
        @name, @type = name, type
      end

      def valid?
        super && (@tsvpipe_command || @parent)
      end
    end
  end
end
