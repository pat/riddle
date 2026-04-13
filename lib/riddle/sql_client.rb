# lib/sql_client.rb

module Riddle::SQLClient
  def self.connection(address = '127.0.0.1', port = 9312, adapter: nil)
    adapter ||= default_adapter
    require_relative "./sql_client/#{adapter}"

    # If you use localhost, MySQL insists on a socket connection, but Sphinx
    # requires a TCP connection. Using 127.0.0.1 fixes that.
    address = '127.0.0.1' if address == 'localhost'

    case adapter.to_sym
    when :trilogy
      Riddle::SQLClient::Trilogy.new(:host => address, :port => port)
    when :mysql2
      Riddle::SQLClient::Mysql2.new(:host => address, :port => port)
    else
      raise ArgumentError, "Unknown adapter #{adapter}"
    end
  end

  def self.default_adapter
    return @default_adapter if @default_adapter
    %w[trilogy mysql2].each do |adapter|
      require adapter
      @default_adapter = adapter.to_sym
      return adapter
    rescue LoadError
    end
    raise "Either Trilogy or mysql2 are required to use the sql interface"
  end

  def self.default_adapter=(adapter)
    @default_adapter = adapter
  end
end
