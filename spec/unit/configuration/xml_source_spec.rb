# frozen_string_literal: true

require 'spec_helper'

describe Riddle::Configuration::XMLSource do
  it "should be invalid without an xmlpipe command, name and type if there's no parent" do
    source = Riddle::Configuration::XMLSource.new("xml1", "xmlpipe")
    expect(source).not_to be_valid
    
    source.xmlpipe_command = "ls /var/null"
    expect(source).to be_valid
    
    source.name = nil
    expect(source).not_to be_valid
    
    source.name = "xml1"
    source.type = nil
    expect(source).not_to be_valid
  end
  
  it "should be invalid without only a name and type if there is a parent" do
    source = Riddle::Configuration::XMLSource.new("xml1", "xmlpipe")
    expect(source).not_to be_valid
    
    source.parent = "xmlparent"
    expect(source).to be_valid
    
    source.name = nil
    expect(source).not_to be_valid
    
    source.name = "xml1"
    source.type = nil
    expect(source).not_to be_valid
  end
  
  it "should raise a ConfigurationError if rendering when not valid" do
    source = Riddle::Configuration::XMLSource.new("xml1", "xmlpipe")
    expect { source.render }.to raise_error(Riddle::Configuration::ConfigurationError)
  end
  
  it "should render correctly when valid" do
    source = Riddle::Configuration::XMLSource.new("xml1", "xmlpipe")
    source.xmlpipe_command = "ls /var/null"
    
    expect(source.render).to eq <<-XMLSOURCE
source xml1
{
  type = xmlpipe
  xmlpipe_command = ls /var/null
}
    XMLSOURCE
  end
end