# frozen_string_literal: true

require 'spec_helper'

describe Riddle::SQLClient, live: true do
  describe '.connection with adapter parameter' do
    it "returns a Trilogy client when adapter is :trilogy" do
      connection = Riddle::SQLClient.connection 'localhost', 9306, adapter: :trilogy
      expect(connection).to be_a(Trilogy)
      connection.close
    end

    it "returns a Mysql2 client when adapter is :mysql2" do
      connection = Riddle::SQLClient.connection 'localhost', 9306, adapter: :mysql2
      expect(connection).to be_a(Mysql2::Client)
      connection.close
    end
  end
end
