# frozen_string_literal: true

require 'spec_helper'

describe "Sphinx Keywords", :live => true do
  before :each do
    @client = Riddle::Client.new("localhost", 9313)
  end
  
  it "should return an array of hashes" do
    results = @client.keywords("pat", "people")
    expect(results).to be_kind_of(Array)
    
    results.each do |result|
      expect(result).to be_kind_of(Hash)
    end
  end
  
  it "should have keys for normalised and tokenised versions of the keywords" do
    results = @client.keywords("pat", "people")
    results.each do |result|
      expect(result.keys).to include(:normalised)
      expect(result.keys).to include(:tokenised)
    end
  end
  
  it "shouldn't have docs or hits keys if not requested" do
    results = @client.keywords("pat", "people")
    results.each do |result|
      expect(result.keys).not_to include(:docs)
      expect(result.keys).not_to include(:hits)
    end
  end
  
  it "should have docs and hits keys if requested" do
    results = @client.keywords("pat", "people", true)
    results.each do |result|
      expect(result.keys).to include(:docs)
      expect(result.keys).to include(:hits)
    end
  end
end