require 'spec_helper'

describe Riddle::Configuration::Common do
  it "should always be valid" do
    common = Riddle::Configuration::Common.new
    common.should be_valid
  end
  
  it "should support Sphinx's common settings" do
    settings = %w( lemmatizer_base on_json_attr_error json_autoconv_numbers
      json_autoconv_keynames rlp_root rlp_environment rlp_max_batch_size
      rlp_max_batch_docs )
    common = Riddle::Configuration::Common.new
    
    settings.each do |setting|
      common.should respond_to(setting.to_sym)
      common.should respond_to("#{setting}=".to_sym)
    end
  end

  it "should render a correct configuration" do
    common = Riddle::Configuration::Common.new
    common.common_sphinx_configuration = true

    common.render.should == <<-COMMON
common
{
}
    COMMON
  
    common.lemmatizer_base = "/tmp"
    common.render.should == <<-COMMON
common
{
  lemmatizer_base = /tmp
}
    COMMON
  end

  it "should not be present when common_sphinx_configuration is not set" do
    common = Riddle::Configuration::Common.new
    common.render.should be_nil
  end

  it "should not be present when common_sphinx_configuration is false" do
    common = Riddle::Configuration::Common.new
    common.common_sphinx_configuration = false
    common.render.should be_nil
  end
  
  it "should render when common_sphinx_configuration is true" do
    common = Riddle::Configuration::Common.new
    common.common_sphinx_configuration = true
    common.render.should == <<-COMMON
common
{
}
    COMMON
  end
end