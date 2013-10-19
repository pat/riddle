module Riddle
  class Configuration
    class Indexer < Riddle::Configuration::Section
      def self.settings
        [
          :mem_limit, :max_iops, :max_iosize, :max_xmlpipe2_field,
          :write_buffer, :max_file_field_buffer, :lemmatizer_base,
          :lemmatizer_cache, :json_autoconv_numbers, :on_json_attr_error
        ]
      end

      attr_accessor *self.settings

      def render
        raise ConfigurationError unless valid?

        (
          ["indexer", "{"] +
          settings_body +
          ["}", ""]
        ).join("\n")
      end
    end
  end
end
