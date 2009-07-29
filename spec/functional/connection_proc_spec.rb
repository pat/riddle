require 'spec/spec_helper'

class RiddleSpecConnectionProcError < StandardError; end

describe "Sphinx Client" do
  before :each do
    @client = Riddle::Client.new("localhost", 3313)
  end

  after :each do
    # change connection_proc back to nil, so other specs will not use it
    Riddle::Client.connection_proc = nil
  end
  
  it "should work with given @connection_proc" do
    @client.connection_proc = lambda { |client| TCPsocket.new(client.server, client.port) }
    @client.query("smith").should be_kind_of(Hash)
  end

  it "should work with given @@connection_proc" do
    Riddle::Client.connection_proc = lambda { |client| TCPsocket.new(client.server, client.port) }
    @client.query("smith").should be_kind_of(Hash)
  end

  it "should run @@connection_proc" do
    Riddle::Client.connection_proc = lambda { |client| raise RiddleSpecConnectionProcError }
    lambda { @client.query("smith") }.should raise_error(RiddleSpecConnectionProcError)
  end
  
  it "should run @connection_proc" do
    @client.connection_proc = lambda { |client| raise RiddleSpecConnectionProcError }
    lambda { @client.query("smith") }.should raise_error(RiddleSpecConnectionProcError)
  end

  it "should run @connection_proc first to allow per object customization" do
    Riddle::Client.connection_proc = lambda { |client| raise RiddleSpecConnectionProcError }
    @client.connection_proc = lambda { |client| TCPsocket.new(client.server, client.port) }
    lambda { @client.query("smith") }.should_not raise_error
  end
end
