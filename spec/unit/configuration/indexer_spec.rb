# frozen_string_literal: true

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

  it "should render shared settings when common_sphinx_configuration is not set" do
    indexer = Riddle::Configuration::Indexer.new
    indexer.rlp_root = '/tmp'
    
    indexer.render.should == <<-INDEXER
indexer
{
  rlp_root = /tmp
}
    INDEXER
  end

  it "should render shared settings when common_sphinx_configuration is false" do
    indexer = Riddle::Configuration::Indexer.new
    indexer.common_sphinx_configuration = false
    indexer.rlp_root = '/tmp'

    indexer.render.should == <<-INDEXER
indexer
{
  rlp_root = /tmp
}
    INDEXER
  end

  it "should not render shared settings when common_sphinx_configuration is true" do
    indexer = Riddle::Configuration::Indexer.new
    indexer.common_sphinx_configuration = true
    indexer.rlp_root = '/tmp'

    indexer.render.should == <<-INDEXER
indexer
{
}
      INDEXER
  end
end