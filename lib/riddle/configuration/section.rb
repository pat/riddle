# frozen_string_literal: true

module Riddle
  class Configuration
    class Section
      def self.settings
        []
      end

      def valid?
        true
      end

      private

      def settings_body
        settings.select { |setting|
          !send(setting).nil?
        }.collect { |setting|
          if send(setting) == ""
            conf = "  #{setting} = "
          else
            conf = setting_to_array(setting).collect { |set|
              "  #{setting} = #{rendered_setting set}"
            }
          end
          conf.length == 0 ? nil : conf
        }.flatten.compact
      end

      def setting_to_array(setting)
        value = send(setting)
        case value
        when Array      then value
        when TrueClass  then [1]
        when FalseClass then [0]
        else
          [value]
        end
      end

      def rendered_setting(setting)
        return setting unless setting.is_a?(String)

        index  = 8100
        output = String.new(setting)

        while index < output.length
          output.insert(index, "\\\n")
          index += 8100
        end

        output
      end

      def settings
        self.class.settings
      end
    end
  end
end
