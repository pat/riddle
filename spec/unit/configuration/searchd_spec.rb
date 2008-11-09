require 'spec/spec_helper'

describe Riddle::Configuration::Searchd do
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
  
  it "should raise a ConfigurationError if rendering but not valid" do
    searchd = Riddle::Configuration::Searchd.new
    searchd.should_not be_valid
    lambda { searchd.render }.should raise_error(Riddle::Configuration::ConfigurationError)
  end
  
  it "should support Sphinx's searchd settings" do
    settings = %w( address port log query_log read_timeout max_children
      pid_file max_matches seamless_rotate preopen_indexes unlink_old )
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
    
    searchd.render.should == <<-SEARCHD
searchd
{
  port = 3312
  pid_file = file.pid
}
    SEARCHD
  end
end