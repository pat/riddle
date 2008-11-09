module Riddle
  class Configuration
    class Section
      class << self
        attr_accessor :settings
      end
      
      settings = []
      
      def valid?
        true
      end
      
      private
      
      def settings_body
        self.class.settings.select { |setting|
          !send(setting).nil?
        }.collect { |setting|
          Array(send(setting)).collect { |set|
            "  #{setting} = #{set}"  
          }.join("\n")
        }
      end
    end
  end
end