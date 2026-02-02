# frozen_string_literal: true

class TrilogyClient
  def initialize(host, username, password, port)
    @client = Trilogy.new(
      :host     => host,
      :username => username,
      :password => password,
      :port     => port
    )
  end

  def query(statement)
    client.query(statement).to_a.flatten
  end

  def execute(statement)
    client.query(statement)
  end

  def close
    @client.close
  end

  private

  attr_reader :client
end
