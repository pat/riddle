require 'spec_helper'

describe Riddle::Client do
  it "should have the same keys for both commands and versions, except persist" do
    
    (Riddle::Client::Commands.keys - [:persist]).should == Riddle::Client::Versions.keys
  end
  
  it "should default to localhost as the server" do
    Riddle::Client.new.server.should == "localhost"
  end
  
  it "should default to port 9312" do
    Riddle::Client.new.port.should == 9312
  end
  
  it "should translate anchor arguments correctly" do
    client = Riddle::Client.new
    client.set_anchor "latitude", 10.0, "longitude", 95.0
    client.anchor.should == {
      :latitude_attribute   => "latitude",
      :latitude             => 10.0,
      :longitude_attribute  => "longitude",
      :longitude            => 95.0
    }
  end
  
  it "should add queries to the queue" do
    client = Riddle::Client.new
    client.queue.should be_empty
    client.append_query "spec"
    client.queue.should_not be_empty
  end
  
  it "should build a basic search message correctly" do
    client = Riddle::Client.new
    client.append_query "test "
    client.queue.first.should == query_contents(:simple)
  end
  
  it "should build a message with a specified index correctly" do
    client = Riddle::Client.new
    client.append_query "test ", "edition"
    client.queue.first.should == query_contents(:index)
  end
  
  it "should build a message using match mode :any correctly" do
    client = Riddle::Client.new
    client.match_mode = :any
    client.append_query "test this "
    client.queue.first.should == query_contents(:any)
  end
  
  it "should build a message using sort by correctly" do
    client = Riddle::Client.new
    client.sort_by = 'id'
    client.sort_mode = :extended
    client.append_query "testing "
    client.queue.first.should == query_contents(:sort)
  end
  
  it "should build a message using match mode :boolean correctly" do
    client = Riddle::Client.new
    client.match_mode = :boolean
    client.append_query "test "
    client.queue.first.should == query_contents(:boolean)
  end
  
  it "should build a message using match mode :phrase correctly" do
    client = Riddle::Client.new
    client.match_mode = :phrase
    client.append_query "testing this "
    client.queue.first.should == query_contents(:phrase)
  end
  
  it "should build a message with a filter correctly" do
    client = Riddle::Client.new
    client.filters << Riddle::Client::Filter.new("id", [10, 100, 1000])
    client.append_query "test "
    client.queue.first.should == query_contents(:filter)
  end
  
  it "should build a message with group values correctly" do
    client = Riddle::Client.new
    client.group_by       = "id"
    client.group_function = :attr
    client.group_clause   = "id"
    client.append_query "test "
    client.queue.first.should == query_contents(:group)
  end
  
  it "should build a message with group distinct value correctly" do
    client = Riddle::Client.new
    client.group_distinct = "id"
    client.append_query "test "
    client.queue.first.should == query_contents(:distinct)
  end
  
  it "should build a message with weights correctly" do
    client = Riddle::Client.new
    client.weights = [100, 1]
    client.append_query "test "
    client.queue.first.should == query_contents(:weights)
  end
  
  it "should build a message with an anchor correctly" do
    client = Riddle::Client.new
    client.set_anchor "latitude", 10.0, "longitude", 95.0
    client.append_query "test "
    client.queue.first.should == query_contents(:anchor)
  end
  
  it "should build a message with index weights correctly" do
    client = Riddle::Client.new
    client.index_weights = {"people" => 101}
    client.append_query "test "
    client.queue.first.should == query_contents(:index_weights)
  end
  
  it "should build a message with field weights correctly" do
    client = Riddle::Client.new
    client.field_weights = {"city" => 101}
    client.append_query "test "
    client.queue.first.should == query_contents(:field_weights)
  end
  
  it "should build a message with a comment correctly" do
    client = Riddle::Client.new
    client.append_query "test ", "*", "commenting"
    client.queue.first.should == query_contents(:comment)
  end
  
  if Riddle.loaded_version == '0.9.9' || Riddle.loaded_version == '1.10'
    it "should build a message with overrides correctly" do
      client = Riddle::Client.new
      client.add_override("rating", :float, {1 => 10.0})
      client.append_query "test "
      client.queue.first.should == query_contents(:overrides)
    end
  
    it "should build a message with selects correctly" do
      client = Riddle::Client.new
      client.select = "selecting"
      client.append_query "test "
      client.queue.first.should == query_contents(:select)
    end
  end
  
  it "should keep multiple messages in the queue" do
    client = Riddle::Client.new
    client.weights = [100, 1]
    client.append_query "test "
    client.append_query "test "
    client.queue.length.should == 2
    client.queue.each { |item| item.should == query_contents(:weights) }
  end
  
  it "should keep multiple messages in the queue with different params" do
    client = Riddle::Client.new
    client.weights = [100, 1]
    client.append_query "test "
    client.weights = []
    client.append_query "test ", "edition"
    client.queue.first.should == query_contents(:weights)
    client.queue.last.should  == query_contents(:index)
  end
  
  it "should build a basic update message correctly" do
    client = Riddle::Client.new
    client.send(
      :update_message,
      "people",
      ["birthday"],
      {1 => [191163600]}
    ).should == query_contents(:update_simple)
  end
  
  it "should build a keywords request without hits correctly" do
    client = Riddle::Client.new
    client.send(
      :keywords_message,
      "pat",
      "people",
      false
    ).should == query_contents(:keywords_without_hits)
  end
  
  it "should build a keywords request with hits correctly" do
    client = Riddle::Client.new
    client.send(
      :keywords_message,
      "pat",
      "people",
      true
    ).should == query_contents(:keywords_with_hits)
  end
  
  it "should timeout after a specified time" do
    client = Riddle::Client.new
    client.port     = 3314
    client.timeout  = 1
    
    server = TCPServer.new "localhost", 3314
    
    lambda {
      client.send(:connect) { |socket| }
    }.should raise_error(Riddle::ConnectionError)
    
    server.close
  end

  context "connection retrying" do
    it "should try fives time when connection refused" do
      client = Riddle::Client.new
      client.port    = 3314

      TCPSocket.should_receive(:new).with('localhost', 3314).exactly(5).times.
        and_raise(Errno::ECONNREFUSED)

      lambda {
        client.send(:connect) { |socket| }
      }.should raise_error(Riddle::ConnectionError)
    end
  end

  context "connection fail over" do
    it "should try each of several server addresses after timeouts" do
      client = Riddle::Client.new
      client.port    = 3314
      client.servers = %w[localhost 127.0.0.1 0.0.0.0]
      client.timeout  = 1

      TCPSocket.should_receive(:new).with(
        an_instance_of(String), 3314
      ).exactly(3).and_raise Timeout::Error

      lambda {
        client.send(:connect) { |socket| }
      }.should raise_error(Riddle::ConnectionError)
    end

    it "should try each of several server addresses after a connection refused" do
      client = Riddle::Client.new
      client.port    = 3314
      client.servers = %w[localhost 127.0.0.1 0.0.0.0]
      client.timeout  = 1

      # initialise_socket will retry 5 times before failing,
      # these combined with the multiple server failover should result in 15
      # calls to TCPSocket.new
      TCPSocket.should_receive(:new).with(
        an_instance_of(String), 3314
      ).exactly(3 * 5).and_raise Errno::ECONNREFUSED

      lambda {
        client.send(:connect) { |socket| }
      }.should raise_error(Riddle::ConnectionError)
    end
  end
end
