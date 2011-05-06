require 'spec_helper'

describe Riddle::Configuration::DistributedIndex do
  it "should not be valid without any indexes" do
    index = Riddle::Configuration::DistributedIndex.new("dist1")
    index.should_not be_valid
  end
  
  it "should be valid with just local indexes" do
    index = Riddle::Configuration::DistributedIndex.new("dist1")
    index.local_indexes << "local_one"
    index.should be_valid
  end
  
  it "should be valid with just remote indexes" do
    index = Riddle::Configuration::DistributedIndex.new("dist1")
    index.remote_indexes << Riddle::Configuration::RemoteIndex.new("local", 3312, "remote_one")
    index.should be_valid
  end
  
  it "should be of type 'distributed'" do
    index = Riddle::Configuration::DistributedIndex.new("dist1")
    index.type.should == 'distributed'
  end
  
  it "should raise a ConfigurationError if rendering when not valid" do
    index = Riddle::Configuration::DistributedIndex.new("dist1")
    lambda { index.render }.should raise_error(Riddle::Configuration::ConfigurationError)
  end
  
  it "should render correctly if supplied settings are valid" do
    index = Riddle::Configuration::DistributedIndex.new("dist1")
    
    index.local_indexes << "test1" << "test1stemmed"
    index.remote_indexes <<
      Riddle::Configuration::RemoteIndex.new("localhost", 3313, "remote1") <<
      Riddle::Configuration::RemoteIndex.new("localhost", 3314, "remote2") <<
      Riddle::Configuration::RemoteIndex.new("localhost", 3314, "remote3")
    index.agent_blackhole << "testbox:3312:testindex1,testindex2"
    
    index.agent_connect_timeout = 1000
    index.agent_query_timeout   = 3000
    
    index.render.should == <<-DISTINDEX
index dist1
{
  type = distributed
  local = test1
  local = test1stemmed
  agent = localhost:3313:remote1
  agent = localhost:3314:remote2,remote3
  agent_blackhole = testbox:3312:testindex1,testindex2
  agent_connect_timeout = 1000
  agent_query_timeout = 3000
}
    DISTINDEX
  end
end