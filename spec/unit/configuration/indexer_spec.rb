require 'spec_helper'

describe Riddle::Configuration::Indexer do
  it "should always be valid" do
    indexer = Riddle::Configuration::Indexer.new
    indexer.should be_valid
  end
  
  it "should support Sphinx's indexer settings" do
    settings = %w( mem_limit max_iops max_iosize )
    indexer = Riddle::Configuration::Indexer.new
    
    settings.each do |setting|
      indexer.should respond_to(setting.to_sym)
      indexer.should respond_to("#{setting}=".to_sym)
    end
  end
  
  it "should render a correct configuration" do
    indexer = Riddle::Configuration::Indexer.new
    
    indexer.render.should == <<-INDEXER
indexer
{
}
    INDEXER
    
    indexer.mem_limit = "32M"
    indexer.render.should == <<-INDEXER
indexer
{
  mem_limit = 32M
}
    INDEXER
  end
end