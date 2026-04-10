# frozen_string_literal: true

require 'spec_helper'

describe Riddle::Configuration::TSVSource do
  it "should be invalid without an tsvpipe command, name and type if there's no parent" do
    source = Riddle::Configuration::TSVSource.new("tsv1")
    expect(source).not_to be_valid

    source.tsvpipe_command = "ls /var/null"
    expect(source).to be_valid

    source.name = nil
    expect(source).not_to be_valid

    source.name = "tsv1"
    source.type = nil
    expect(source).not_to be_valid
  end

  it "should be invalid without only a name and type if there is a parent" do
    source = Riddle::Configuration::TSVSource.new("tsv1")
    expect(source).not_to be_valid

    source.parent = "tsvparent"
    expect(source).to be_valid

    source.name = nil
    expect(source).not_to be_valid

    source.name = "tsv1"
    source.type = nil
    expect(source).not_to be_valid
  end

  it "should raise a ConfigurationError if rendering when not valid" do
    source = Riddle::Configuration::TSVSource.new("tsv1")
    expect {
      source.render
    }.to raise_error(Riddle::Configuration::ConfigurationError)
  end

  it "should render correctly when valid" do
    source = Riddle::Configuration::TSVSource.new("tsv1")
    source.tsvpipe_command = "ls /var/null"

    expect(source.render).to eq <<-TSVSOURCE
source tsv1
{
  type = tsvpipe
  tsvpipe_command = ls /var/null
}
    TSVSOURCE
  end
end
