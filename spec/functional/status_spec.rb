require 'spec/spec_helper'

describe "Sphinx Status" do
  before :each do
    @client = Riddle::Client.new("localhost", 3313)
  end
  
  it "should be unsupported" do
    lambda {
      @client.status
    }.should raise_error(Riddle::ResponseError)
  end
end