# frozen_string_literal: true

require 'spec_helper'

describe "Sphinx Searches", :live => true do
  let(:client) { Riddle::Client.new 'localhost', 9313 }

  it "should return a single hash if a single query" do
    expect(client.query("smith", "people")).to be_kind_of(Hash)
  end

  it "should return an array of hashs if multiple queries are run" do
    client.append_query "smith", "people"
    client.append_query "jones", "people"
    results = client.run
    expect(results).to be_kind_of(Array)
    results.each { |result| expect(result).to be_kind_of(Hash) }
  end

  it "should return an array of matches" do
    matches = client.query("smith", "people")[:matches]
    expect(matches).to be_kind_of(Array)
    matches.each { |match| expect(match).to be_kind_of(Hash) }
  end

  it "should return an array of string fields" do
    fields = client.query("smith", "people")[:fields]
    expect(fields).to be_kind_of(Array)
    fields.each { |field| expect(field).to be_kind_of(String) }
  end

  it "should return an array of attribute names" do
    attributes = client.query("smith", "people")[:attribute_names]
    expect(attributes).to be_kind_of(Array)
    attributes.each { |a| expect(a).to be_kind_of(String) }
  end

  it "should return a hash of attributes" do
    attributes = client.query("smith", "people")[:attributes]
    expect(attributes).to be_kind_of(Hash)
    attributes.each do |key,value|
      expect(key).to be_kind_of(String)
      expect(value).to be_kind_of(Integer)
    end
  end

  it "should return the total number of results returned" do
    expect(client.query("smith", "people")[:total]).to be_kind_of(Integer)
  end

  it "should return the total number of results available" do
    expect(client.query("smith", "people")[:total_found]).to be_kind_of(Integer)
  end

  it "should return the time taken for the query as a float" do
    expect(client.query("smith", "people")[:time]).to be_kind_of(Float)
  end

  it "should return a hash of the words from the query, with the number of documents and the number of hits" do
    words = client.query("smith victoria", "people")[:words]
    expect(words).to be_kind_of(Hash)
    words.each do |word,hash|
      expect(word).to be_kind_of(String)
      expect(hash).to be_kind_of(Hash)
      expect(hash[:docs]).to be_kind_of(Integer)
      expect(hash[:hits]).to be_kind_of(Integer)
    end
  end
end
