# frozen_string_literal: true

require 'spec_helper'

class RiddleSpecConnectionProcError < StandardError; end

describe 'Sphinx Client', :live => true do
  let(:client) { Riddle::Client.new 'localhost', 9313 }

  after :each do
    Riddle::Client.connection = nil
  end

  describe '.connection' do
    it "should use the given block" do
      Riddle::Client.connection = lambda { |client|
        TCPSocket.new(client.server, client.port)
      }
      expect(client.query('smith')).to be_kind_of(Hash)
    end

    it "should fail with errors from the given block" do
      Riddle::Client.connection = lambda { |client|
        raise RiddleSpecConnectionProcError
      }
      expect { client.query('smith') }.
        to raise_error(Riddle::ResponseError)
    end
  end

  describe '#connection' do
    it "use the given block" do
      client.connection = lambda { |client|
        TCPSocket.new(client.server, client.port)
      }
      expect(client.query('smith')).to be_kind_of(Hash)
    end

    it "should fail with errors from the given block" do
      client.connection = lambda { |client|
        raise RiddleSpecConnectionProcError
      }
      expect { client.query('smith') }.
        to raise_error(Riddle::ResponseError)
    end

    it "should not override OutOfBoundsError instances" do
      client.connection = lambda { |client|
        raise Riddle::OutOfBoundsError
      }
      expect { client.query('smith') }.
        to raise_error(Riddle::OutOfBoundsError)
    end

    it "should prioritise instance over class connection" do
      Riddle::Client.connection = lambda { |client|
        raise RiddleSpecConnectionProcError
      }
      client.connection = lambda { |client|
        TCPSocket.new(client.server, client.port)
      }

      expect { client.query('smith') }.not_to raise_error
    end
  end
end
