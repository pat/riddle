module Riddle
  class Client
    # Used to interrogate responses from the Sphinx daemon. Keep in mind none
    # of the methods here check whether the data they're grabbing are what the
    # user expects - it just assumes the user knows what the data stream is
    # made up of.
    class Response

      # Create with the data to interpret
      def initialize(str)
        @str = str
        @marker = 0
      end
      
      # Return the next string value in the stream
      def next
        len = next_int
        result = @str[@marker, len]
        @marker += len
        
        Response.encoding_proc.call(result, ::Encoding.default_external) # use call instead of yield for 1.8 compatibility
      end
      
      # Return the next integer value from the stream
      def next_int
        int = @str[@marker, 4].unpack('N*').first
        @marker += 4
        
        int
      end
      
      def next_64bit_int
        high, low = @str[@marker, 8].unpack('N*N*')[0..1]
        @marker += 8
        
        (high << 32) + low
      end
      
      # Return the next float value from the stream
      def next_float
        float = @str[@marker, 4].unpack('N*').pack('L').unpack('f*').first
        @marker += 4
        
        float
      end
      
      # Returns an array of string items
      def next_array
        count = next_int
        items = []
        for i in 0...count
          items << self.next
        end
        
        items
      end
      
      # Returns an array of int items
      def next_int_array
        count = next_int
        items = []
        for i in 0...count
          items << self.next_int
        end
        
        items
      end
      
      def next_float_array
        count = next_int
        items = []
        for i in 0...count
          items << self.next_float
        end
        
        items
      end
      
      def next_64bit_int_array
        count = next_int
        items = []
        for i in 0...count
          items << self.next_64bit_int
        end
        
        items
      end
      
      # Returns the length of the streamed data
      def length
        @str.length
      end

      # Use default encoding if available (1.9)
      def self.encoding_proc
        @@encoding_proc ||= if (defined?(::Encoding) && ::Encoding.respond_to?(:default_external))
                              lambda{|s,e| s.force_encoding(e) }
                            else
                              lambda{|s,e| s }
                            end
      end
    end
  end
end
