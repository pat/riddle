# frozen_string_literal: true

class MRIClient
  def initialize(host, username, password)
    @client = Mysql2::Client.new(
      :host     => host,
      :username => username,
      :password => password
    )
  end

  def query(statement)
    client.query(statement, :as => :array).to_a.flatten
  end

  def execute(statement)
    client.query statement
  end

  def close
    @client.close
  end

  private

  attr_reader :client
end
