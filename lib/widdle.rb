require 'thread'
require 'socket'
require 'timeout'

module Widdle #:nodoc:
  @@mutex          = Mutex.new
  @@escape_pattern = /[\(\)\|\-!@~"&\/]/
  @@use_encoding   = defined?(::Encoding) &&
                     ::Encoding.respond_to?(:default_external)
  
  class ConnectionError < StandardError #:nodoc:
    #
  end

  def self.encode(data, encoding = defined?(::Encoding) && ::Encoding.default_external)
    if @@use_encoding
      data.force_encoding(encoding)
    else
      data
    end
  end
  
  def self.mutex
    @@mutex
  end
  
  def self.escape_pattern
    @@escape_pattern
  end
  
  def self.escape_pattern=(pattern)
    mutex.synchronize do
      @@escape_pattern = pattern
    end
  end
  
  def self.escape(string)
    string.gsub(escape_pattern) { |char| "\\#{char}" }
  end
  
  def self.loaded_version
    @@sphinx_version
  end
  
  def self.loaded_version=(version)
    @@sphinx_version = version
  end
  
  def self.version_warning
    return if loaded_version
    
    STDERR.puts %Q{
Widdle cannot detect Sphinx on your machine, and so can't determine which
version of Sphinx you are using. Please specify the Sphinx version in your
Widdle configuration options or by setting Widdle.loaded_version = '2.0.1'
    }
  end

end

Widdle.loaded_version = nil

require 'widdle/configuration'
require 'widdle/controller'
require 'widdle/query'

