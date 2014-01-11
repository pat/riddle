require 'spec_helper'

describe Riddle::Configuration::TSVSource do
  it "should be invalid without an tsvpipe command, name and type if there's no parent" do
    source = Riddle::Configuration::TSVSource.new("tsv1")
    source.should_not be_valid

    source.tsvpipe_command = "ls /var/null"
    source.should be_valid

    source.name = nil
    source.should_not be_valid

    source.name = "tsv1"
    source.type = nil
    source.should_not be_valid
  end

  it "should be invalid without only a name and type if there is a parent" do
    source = Riddle::Configuration::TSVSource.new("tsv1")
    source.should_not be_valid

    source.parent = "tsvparent"
    source.should be_valid

    source.name = nil
    source.should_not be_valid

    source.name = "tsv1"
    source.type = nil
    source.should_not be_valid
  end

  it "should raise a ConfigurationError if rendering when not valid" do
    source = Riddle::Configuration::TSVSource.new("tsv1")
    lambda {
      source.render
    }.should raise_error(Riddle::Configuration::ConfigurationError)
  end

  it "should render correctly when valid" do
    source = Riddle::Configuration::TSVSource.new("tsv1")
    source.tsvpipe_command = "ls /var/null"

    source.render.should == <<-TSVSOURCE
source tsv1
{
  type = tsvpipe
  tsvpipe_command = ls /var/null
}
    TSVSOURCE
  end
end
