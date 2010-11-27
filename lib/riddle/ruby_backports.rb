module Riddle
  module RubyBackports
    module ArrayShuffle
      # Standard in Ruby 1.8.7+. See official documentation[http://ruby-doc.org/core-1.9/classes/Array.html]
      def shuffle
        dup.shuffle!
      end unless method_defined? :shuffle

      # Standard in Ruby 1.8.7+. See official documentation[http://ruby-doc.org/core-1.9/classes/Array.html]
      def shuffle!
        size.times do |i|
          r = i + Kernel.rand(size - i)
          self[i], self[r] = self[r], self[i]
        end
        self
      end unless method_defined? :shuffle!
    end
  end
end

Array.send(:include, Riddle::RubyBackports::ArrayShuffle)

