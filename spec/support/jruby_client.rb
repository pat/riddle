# frozen_string_literal: true

class JRubyClient
  def initialize(host, username, password, port)
    address    = "jdbc:mysql://#{host}"
    properties = Java::JavaUtil::Properties.new
    properties.setProperty "user", username     if username
    properties.setProperty "password", password if password
    properties.setProperty "port", port if port
    properties.setProperty "useSSL", "false"
    properties.setProperty "allowLoadLocalInfile", "true"

    @client = Java::ComMysqlJdbc::Driver.new.connect address, properties
  end

  def query(statement)
    set     = client.createStatement.executeQuery(statement)
    results = []
    results << set.getString(1) while set.next
    results
  end

  def execute(statement)
    client.createStatement.execute statement
  end

  def close
    @client.close
  end

  private

  attr_reader :client
end
