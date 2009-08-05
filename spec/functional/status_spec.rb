require 'spec/spec_helper'

describe "Sphinx Status" do
  before :each do
    @client = Riddle::Client.new("localhost", 3313)
    @status = @client.status
  end
  
  it "should return a hash" do
    @status.should be_a(Hash)
  end
  
  it "should include the uptime, connections, and command_search keys" do
    # Not checking all values, but ensuring keys are being set correctly
    @status[:uptime].should_not be_nil
    @status[:connections].should_not be_nil
    @status[:command_search].should_not be_nil
  end
end
