# frozen_string_literal: true

module Riddle
  class Configuration
    class Indexer < Riddle::Configuration::Section
      def self.settings
        [
          :mem_limit, :max_iops, :max_iosize, :max_xmlpipe2_field,
          :write_buffer, :max_file_field_buffer, :on_file_field_error,
          :lemmatizer_cache
        ] + shared_settings
      end

      def self.shared_settings
        [
          :lemmatizer_base, :json_autoconv_numbers, :json_autoconv_keynames,
          :on_json_attr_error, :rlp_root, :rlp_environment, :rlp_max_batch_size,
          :rlp_max_batch_docs
        ]
      end

      attr_accessor :common_sphinx_configuration, *settings

      def render
        raise ConfigurationError unless valid?

        (
          ["indexer", "{"] +
          settings_body +
          ["}", ""]
        ).join("\n")
      end


      private

      def settings
        settings = self.class.settings
        settings -= self.class.shared_settings if common_sphinx_configuration
        settings
      end
    end
  end
end
