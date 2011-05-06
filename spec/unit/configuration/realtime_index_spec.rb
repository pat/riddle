require 'spec_helper'

describe Riddle::Configuration::RealtimeIndex do
  let(:index) { Riddle::Configuration::RealtimeIndex.new('rt1') }
  
  describe '#valid?' do
    it "should not be valid without a name" do
      index.name = nil
      index.path = 'foo'
      index.should_not be_valid
    end
    
    it "should not be valid without a path" do
      index.path = nil
      index.should_not be_valid
    end
    
    it "should be valid with a name and path" do
      index.path = 'foo'
      index.should be_valid
    end
  end
  
  describe '#type' do
    it "should be 'rt'" do
      index.type.should == 'rt'
    end
  end
  
  describe '#render' do
    it "should raise a ConfigurationError if rendering when not valid" do
      lambda {
        index.render
      }.should raise_error(Riddle::Configuration::ConfigurationError)
    end
  
    it "should render correctly if supplied settings are valid" do
      index.path = '/var/data/rt'
      index.rt_mem_limit = '512M'
      index.rt_field << 'title' << 'content'
      
      index.rt_attr_uint      << 'gid'
      index.rt_attr_bigint    << 'guid'
      index.rt_attr_float     << 'gpa'
      index.rt_attr_timestamp << 'ts_added'
      index.rt_attr_string    << 'author'
          
      index.render.should == <<-RTINDEX
index rt1
{
  type = rt
  path = /var/data/rt
  rt_mem_limit = 512M
  rt_field = title
  rt_field = content
  rt_attr_uint = gid
  rt_attr_bigint = guid
  rt_attr_float = gpa
  rt_attr_timestamp = ts_added
  rt_attr_string = author
}
      RTINDEX
    end
  end
end
