# frozen_string_literal: true

class MRIClient
  def initialize(host, username, password, port)
    @client = Mysql2::Client.new(
      :host         => host,
      :username     => username,
      :password     => password,
      :port         => port,
      :local_infile => true
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
