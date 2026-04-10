# frozen_string_literal: true

require 'spec_helper'

describe Riddle::Client do
  it "should have the same keys for both commands and versions, except persist" do
    
    expect(Riddle::Client::Commands.keys - [:persist]).to eq(Riddle::Client::Versions.keys)
  end
  
  it "should default to localhost as the server" do
    expect(Riddle::Client.new.server).to eq("localhost")
  end
  
  it "should default to port 9312" do
    expect(Riddle::Client.new.port).to eq(9312)
  end

  it "should accept an array of servers" do
    servers = ["1.1.1.1", "2.2.2.2", "3.3.3.3"]
    client = Riddle::Client.new(servers)
    expect(client.servers).to eq(servers)
  end
  
  it "should translate anchor arguments correctly" do
    client = Riddle::Client.new
    client.set_anchor "latitude", 10.0, "longitude", 95.0
    expect(client.anchor).to eq({
      :latitude_attribute   => "latitude",
      :latitude             => 10.0,
      :longitude_attribute  => "longitude",
      :longitude            => 95.0
    })
  end
  
  it "should add queries to the queue" do
    client = Riddle::Client.new
    expect(client.queue).to be_empty
    client.append_query "spec"
    expect(client.queue).not_to be_empty
  end
  
  describe 'query contents' do
    it "should build a basic search message correctly" do
      client = Riddle::Client.new
      client.append_query "test "
      expect(client.queue.first).to eq(query_contents(:simple))
    end
  
    it "should build a message with a specified index correctly" do
      client = Riddle::Client.new
      client.append_query "test ", "edition"
      expect(client.queue.first).to eq(query_contents(:index))
    end
  
    it "should build a message using match mode :any correctly" do
      client = Riddle::Client.new
      client.match_mode = :any
      client.append_query "test this "
      expect(client.queue.first).to eq(query_contents(:any))
    end
  
    it "should build a message using sort by correctly" do
      client = Riddle::Client.new
      client.sort_by = 'id'
      client.sort_mode = :extended
      client.append_query "testing "
      expect(client.queue.first).to eq(query_contents(:sort))
    end
  
    it "should build a message using match mode :boolean correctly" do
      client = Riddle::Client.new
      client.match_mode = :boolean
      client.append_query "test "
      expect(client.queue.first).to eq(query_contents(:boolean))
    end
  
    it "should build a message using match mode :phrase correctly" do
      client = Riddle::Client.new
      client.match_mode = :phrase
      client.append_query "testing this "
      expect(client.queue.first).to eq(query_contents(:phrase))
    end
  
    it "should build a message with a filter correctly" do
      client = Riddle::Client.new
      client.filters << Riddle::Client::Filter.new("id", [10, 100, 1000])
      client.append_query "test "
      expect(client.queue.first).to eq(query_contents(:filter))
    end
  
    it "should build a message with group values correctly" do
      client = Riddle::Client.new
      client.group_by       = "id"
      client.group_function = :attr
      client.group_clause   = "id"
      client.append_query "test "
      expect(client.queue.first).to eq(query_contents(:group))
    end
  
    it "should build a message with group distinct value correctly" do
      client = Riddle::Client.new
      client.group_distinct = "id"
      client.append_query "test "
      expect(client.queue.first).to eq(query_contents(:distinct))
    end
  
    it "should build a message with weights correctly" do
      client = Riddle::Client.new
      client.weights = [100, 1]
      client.append_query "test "
      expect(client.queue.first).to eq(query_contents(:weights))
    end
  
    it "should build a message with an anchor correctly" do
      client = Riddle::Client.new
      client.set_anchor "latitude", 10.0, "longitude", 95.0
      client.append_query "test "
      expect(client.queue.first).to eq(query_contents(:anchor))
    end
  
    it "should build a message with index weights correctly" do
      client = Riddle::Client.new
      client.index_weights = {"people" => 101}
      client.append_query "test "
      expect(client.queue.first).to eq(query_contents(:index_weights))
    end
  
    it "should build a message with field weights correctly" do
      client = Riddle::Client.new
      client.field_weights = {"city" => 101}
      client.append_query "test "
      expect(client.queue.first).to eq(query_contents(:field_weights))
    end
  
    it "should build a message with a comment correctly" do
      client = Riddle::Client.new
      client.append_query "test ", "*", "commenting"
      expect(client.queue.first).to eq(query_contents(:comment))
    end
  
    if Riddle.loaded_version == '0.9.9' || Riddle.loaded_version == '1.10'
      it "should build a message with overrides correctly" do
        client = Riddle::Client.new
        client.add_override("rating", :float, {1 => 10.0})
        client.append_query "test "
        expect(client.queue.first).to eq(query_contents(:overrides))
      end
  
      it "should build a message with selects correctly" do
        client = Riddle::Client.new
        client.select = "selecting"
        client.append_query "test "
        expect(client.queue.first).to eq(query_contents(:select))
      end
    end
  
    it "should keep multiple messages in the queue" do
      client = Riddle::Client.new
      client.weights = [100, 1]
      client.append_query "test "
      client.append_query "test "
      expect(client.queue.length).to eq(2)
      client.queue.each { |item| expect(item).to eq(query_contents(:weights)) }
    end
  
    it "should keep multiple messages in the queue with different params" do
      client = Riddle::Client.new
      client.weights = [100, 1]
      client.append_query "test "
      client.weights = []
      client.append_query "test ", "edition"
      expect(client.queue.first).to eq(query_contents(:weights))
      expect(client.queue.last).to  eq(query_contents(:index))
    end
  
    it "should build a basic update message correctly" do
      client = Riddle::Client.new
      expect(client.send(
        :update_message,
        "people",
        ["birthday"],
        {1 => [191163600]}
      )).to eq(query_contents(:update_simple))
    end
  
    it "should build a keywords request without hits correctly" do
      client = Riddle::Client.new
      expect(client.send(
        :keywords_message,
        "pat",
        "people",
        false
      )).to eq(query_contents(:keywords_without_hits))
    end
  
    it "should build a keywords request with hits correctly" do
      client = Riddle::Client.new
      expect(client.send(
        :keywords_message,
        "pat",
        "people",
        true
      )).to eq(query_contents(:keywords_with_hits))
    end
  end
  
  it "should timeout after a specified time" do
    client = Riddle::Client.new
    client.port     = 9314
    client.timeout  = 1
    
    server = TCPServer.new "localhost", 9314
    
    expect {
      client.send(:connect) { |socket| }
    }.to raise_error(Riddle::ConnectionError)
    
    server.close
  end unless RUBY_PLATFORM == 'java' # JRuby doesn't like Timeout

  context "connection retrying" do
    it "should try fives time when connection refused" do
      client = Riddle::Client.new
      client.port    = 3314

      expect(TCPSocket).to receive(:new).with('localhost', 3314).exactly(5).times.
        and_raise(Errno::ECONNREFUSED)

      expect {
        client.send(:connect) { |socket| }
      }.to raise_error(Riddle::ConnectionError)
    end
  end

  context "connection fail over" do
    it "should try each of several server addresses after timeouts" do
      client = Riddle::Client.new
      client.port    = 3314
      client.servers = %w[localhost 127.0.0.1 0.0.0.0]
      client.timeout  = 1

      expect(TCPSocket).to receive(:new).with(
        an_instance_of(String), 3314
      ).exactly(3).and_raise Timeout::Error

      expect {
        client.send(:connect) { |socket| }
      }.to raise_error(Riddle::ConnectionError)
    end unless RUBY_PLATFORM == 'java' # JRuby doesn't like Timeout

    it "should try each of several server addresses after a connection refused" do
      client = Riddle::Client.new
      client.port    = 3314
      client.servers = %w[localhost 127.0.0.1 0.0.0.0]
      client.timeout  = 1

      # initialise_socket will retry 5 times before failing,
      # these combined with the multiple server failover should result in 15
      # calls to TCPSocket.new
      expect(TCPSocket).to receive(:new).with(
        an_instance_of(String), 3314
      ).exactly(3 * 5).and_raise Errno::ECONNREFUSED

      expect {
        client.send(:connect) { |socket| }
      }.to raise_error(Riddle::ConnectionError)
    end unless RUBY_PLATFORM == 'java' # JRuby doesn't like Timeout
  end

  it "should fail if the server has the wrong version" do
    client = Riddle::Client.new
    client.port     = 9314
    client.timeout  = 1

    server = TCPServer.new "localhost", 9314

    thread = Thread.new do
      client = server.accept
      client.send [0].pack("N"), 0
      client.close
    end

    expect {
      client.send(:connect) { |socket| }
    }.to raise_error(Riddle::VersionError)

    thread.exit
    server.close
  end

end
