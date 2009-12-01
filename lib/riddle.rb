require 'socket'
require 'timeout'

module Riddle #:nodoc:
  class ConnectionError < StandardError #:nodoc:
    #
  end
  
  def self.escape_pattern
    Thread.current[:riddle_escape_pattern] ||= /[\(\)\|\-!@~"&\/]/
  end
  
  def self.escape_pattern=(pattern)
    Thread.current[:riddle_escape_pattern] = pattern
  end
  
  def self.escape(string)
    string.gsub(escape_pattern) { |char| "\\#{char}" }
  end
end

require 'riddle/auto_version'
require 'riddle/client'
require 'riddle/configuration'
require 'riddle/controller'

Riddle::AutoVersion.configure
