require 'spec_helper'

class RiddleSpecConnectionProcError < StandardError; end

describe "Sphinx Client" do
  before :each do
    @client = Riddle::Client.new("localhost", 9313)
  end

  after :each do
    Riddle::Client.connection = nil
  end
  
  describe '.connection' do
    it "should use the given block" do
      Riddle::Client.connection = lambda { |client|
        TCPSocket.new(client.server, client.port)
      }
      @client.query("smith").should be_kind_of(Hash)
    end
    
    it "should fail with errors from the given block" do
      Riddle::Client.connection = lambda { |client|
        raise RiddleSpecConnectionProcError
      }
      lambda { @client.query("smith") }.
        should raise_error(RiddleSpecConnectionProcError)
    end
  end
  
  describe '#connection' do
    it "use the given block" do
      @client.connection = lambda { |client|
        TCPSocket.new(client.server, client.port)
      }
      @client.query("smith").should be_kind_of(Hash)
    end

    it "should fail with errors from the given block" do
      @client.connection = lambda { |client|
        raise RiddleSpecConnectionProcError
      }
      lambda { @client.query("smith") }.
        should raise_error(RiddleSpecConnectionProcError)
    end

    it "should prioritise instance over class connection" do
      Riddle::Client.connection = lambda { |client|
        raise RiddleSpecConnectionProcError
      }
      @client.connection = lambda { |client|
        TCPSocket.new(client.server, client.port)
      }
    
      lambda { @client.query("smith") }.should_not raise_error
    end
  end
end
