# frozen_string_literal: true

module Riddle
  class Configuration
    class Common < Riddle::Configuration::Section
      def self.settings
        [
          :lemmatizer_base, :json_autoconv_numbers, :json_autoconv_keynames,
          :on_json_attr_error, :rlp_root, :rlp_environment, :rlp_max_batch_size,
          :rlp_max_batch_docs, :plugin_dir
        ]
      end

      attr_accessor :common_sphinx_configuration, *settings

      def render
        return unless common_sphinx_configuration
        raise ConfigurationError unless valid?

        (
          ["common", "{"] +
          settings_body +
          ["}", ""]
        ).join("\n")
      end
    end
  end
end
