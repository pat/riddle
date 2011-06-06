require 'spec_helper'

describe Riddle::Configuration::Searchd do
  if Riddle.loaded_version.to_f >= 0.9
    it "should be invalid without a listen or pid_file" do
      searchd = Riddle::Configuration::Searchd.new
      searchd.should_not be_valid
      
      searchd.port = 3312
      searchd.should_not be_valid
      
      searchd.pid_file = "file.pid"
      searchd.should be_valid
      
      searchd.port    = nil
      searchd.listen  = nil
      searchd.should_not be_valid
      
      searchd.listen = "localhost:3312"
      searchd.should be_valid
    end
  else
    it "should be invalid without a port or pid_file" do
      searchd = Riddle::Configuration::Searchd.new
      searchd.should_not be_valid

      searchd.port = 3312
      searchd.should_not be_valid

      searchd.pid_file = "file.pid"
      searchd.should be_valid

      searchd.port = nil
      searchd.should_not be_valid
    end
  end
  
  it "should raise a ConfigurationError if rendering but not valid" do
    searchd = Riddle::Configuration::Searchd.new
    searchd.should_not be_valid
    lambda { searchd.render }.should raise_error(Riddle::Configuration::ConfigurationError)
  end
  
  it "should support Sphinx's searchd settings" do
    settings = %w( listen address port log query_log read_timeout
      client_timeout max_children pid_file max_matches seamless_rotate
      preopen_indexes unlink_old attr_flush_period ondisk_dict_default
      max_packet_size mva_updates_pool crash_log_path max_filters
      max_filter_values )
    searchd = Riddle::Configuration::Searchd.new
    
    settings.each do |setting|
      searchd.should respond_to(setting.to_sym)
      searchd.should respond_to("#{setting}=".to_sym)
    end
  end
  
  it "should render a correct configuration with valid settings" do
    searchd = Riddle::Configuration::Searchd.new
    searchd.port      = 3312
    searchd.pid_file  = "file.pid"
    
    if Riddle.loaded_version.to_f >= 0.9
      searchd.render.should == <<-SEARCHD
searchd
{
  listen = 3312
  pid_file = file.pid
}
      SEARCHD
    else
      searchd.render.should == <<-SEARCHD
searchd
{
  port = 3312
  pid_file = file.pid
}
      SEARCHD
    end
  end
  
  it "should render with a client key if one is provided" do
    searchd = Riddle::Configuration::Searchd.new
    searchd.port       = 3312
    searchd.pid_file   = 'file.pid'
    searchd.client_key = 'secret'
    
    if Riddle.loaded_version.to_f >= 0.9
      searchd.render.should == <<-SEARCHD
searchd
{
  listen = 3312
  pid_file = file.pid
  client_key = secret
}
      SEARCHD
    else
      searchd.render.should == <<-SEARCHD
searchd
{
  port = 3312
  pid_file = file.pid
  client_key = secret
}
      SEARCHD
    end
  end
  
  if Riddle.loaded_version.to_f >= 0.9
    it "should render with mysql41 on the default port if true" do
      searchd = Riddle::Configuration::Searchd.new
      searchd.mysql41  = true
      searchd.pid_file = 'file.pid'
      
      searchd.render.should == <<-SEARCHD
searchd
{
  listen = 9306:mysql41
  pid_file = file.pid
}
      SEARCHD
    end
    
    it "should render with mysql41 on a given port" do
      searchd = Riddle::Configuration::Searchd.new
      searchd.mysql41  = 9307
      searchd.pid_file = 'file.pid'
      
      searchd.render.should == <<-SEARCHD
searchd
{
  listen = 9307:mysql41
  pid_file = file.pid
}
      SEARCHD
    end
    
    it "allows for both normal and mysql41 connections" do
      searchd = Riddle::Configuration::Searchd.new
      searchd.mysql41  = true
      searchd.port     = 9312
      searchd.pid_file = 'file.pid'
      
      searchd.render.should == <<-SEARCHD
searchd
{
  listen = 9312
  listen = 9306:mysql41
  pid_file = file.pid
}
      SEARCHD
    end
    
    it "uses given address for mysql41 connections" do
      searchd = Riddle::Configuration::Searchd.new
      searchd.mysql41  = true
      searchd.address  = '127.0.0.1'
      searchd.pid_file = 'file.pid'
      
      searchd.render.should == <<-SEARCHD
searchd
{
  listen = 127.0.0.1:9306:mysql41
  pid_file = file.pid
}
      SEARCHD
    end
    
    it "applies the given address to both normal and mysql41 connections" do
      searchd = Riddle::Configuration::Searchd.new
      searchd.mysql41  = true
      searchd.port     = 9312
      searchd.address  = 'sphinx.server.local'
      searchd.pid_file = 'file.pid'
      
      searchd.render.should == <<-SEARCHD
searchd
{
  listen = sphinx.server.local:9312
  listen = sphinx.server.local:9306:mysql41
  pid_file = file.pid
}
      SEARCHD
    end
  end
end
