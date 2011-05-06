require 'spec_helper'

describe "Sphinx Persistance Connection" do
  before :each do
    @client = Riddle::Client.new("localhost", 9313)
  end
  
  it "should raise errors once already opened" do
    @client.open
    lambda { @client.open }.should raise_error
    @client.close
  end
  
  it "should raise errors if closing when already closed" do
    lambda { @client.close }.should raise_error
  end
end