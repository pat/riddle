require 'spec_helper'

if Riddle.loaded_version == '0.9.9' || Riddle.loaded_version == '1.10'
  describe "Sphinx Status" do
    before :each do
      @client = Riddle::Client.new("localhost", 9313)
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
end