# frozen_string_literal: true

require 'spec_helper'

describe "Sphinx Searches", :live => true do
  let(:client) { Riddle::Client.new 'localhost', 9313 }

  it "should return a single hash if a single query" do
    client.query("smith", "people").should be_kind_of(Hash)
  end

  it "should return an array of hashs if multiple queries are run" do
    client.append_query "smith", "people"
    client.append_query "jones", "people"
    results = client.run
    results.should be_kind_of(Array)
    results.each { |result| result.should be_kind_of(Hash) }
  end

  it "should return an array of matches" do
    matches = client.query("smith", "people")[:matches]
    matches.should be_kind_of(Array)
    matches.each { |match| match.should be_kind_of(Hash) }
  end

  it "should return an array of string fields" do
    fields = client.query("smith", "people")[:fields]
    fields.should be_kind_of(Array)
    fields.each { |field| field.should be_kind_of(String) }
  end

  it "should return an array of attribute names" do
    attributes = client.query("smith", "people")[:attribute_names]
    attributes.should be_kind_of(Array)
    attributes.each { |a| a.should be_kind_of(String) }
  end

  it "should return a hash of attributes" do
    attributes = client.query("smith", "people")[:attributes]
    attributes.should be_kind_of(Hash)
    attributes.each do |key,value|
      key.should be_kind_of(String)
      value.should be_kind_of(Integer)
    end
  end

  it "should return the total number of results returned" do
    client.query("smith", "people")[:total].should be_kind_of(Integer)
  end

  it "should return the total number of results available" do
    client.query("smith", "people")[:total_found].should be_kind_of(Integer)
  end

  it "should return the time taken for the query as a float" do
    client.query("smith", "people")[:time].should be_kind_of(Float)
  end

  it "should return a hash of the words from the query, with the number of documents and the number of hits" do
    words = client.query("smith victoria", "people")[:words]
    words.should be_kind_of(Hash)
    words.each do |word,hash|
      word.should be_kind_of(String)
      hash.should be_kind_of(Hash)
      hash[:docs].should be_kind_of(Integer)
      hash[:hits].should be_kind_of(Integer)
    end
  end
end
