module Riddle
  class Configuration
    class Indexer < Riddle::Configuration::Section
      class << self
        def settings
          [ 
            :mem_limit, :max_iops, :max_iosize, :max_xmlpipe2_field,
            :write_buffer, :max_file_field_buffer
          ]
        end
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
