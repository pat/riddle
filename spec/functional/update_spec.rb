# frozen_string_literal: true

require 'spec_helper'

describe "Sphinx Updates", :live => true do
  before :each do
    @client = Riddle::Client.new("localhost", 9313)
  end

  it "should update a single record appropriately" do
    # check existing birthday
    result = @client.query("Ellie K Ford", "people")
    expect(result[:matches]).not_to be_empty
    expect(result[:matches].length).to eq(1)
    ellie = result[:matches].first
    expect(ellie[:attributes]["birthday"]).to eq(Time.local(1970, 1, 23).to_i)

    # make Ellie younger by 6 years
    @client.update("people", ["birthday"], {ellie[:doc] => [Time.local(1976, 1, 23).to_i]})

    # check attribute's value
    result = @client.query("Ellie K Ford", "people")
    expect(result[:matches]).not_to be_empty
    expect(result[:matches].length).to eq(1)
    ellie = result[:matches].first
    expect(ellie[:attributes]["birthday"]).to eq(Time.local(1976, 1, 23).to_i)
  end

  it "should update multiple records appropriately" do
    result = @client.query("Steele", "people")
    pairs = {}
    result[:matches].each do |match|
      pairs[match[:doc]] = [match[:attributes]["birthday"] + (365*24*60*60)]
    end

    @client.update "people", ["birthday"], pairs

    result = @client.query("Steele", "people")
    result[:matches].each do |match|
      expect(match[:attributes]["birthday"]).to eq(pairs[match[:doc]].first)
    end
  end
end
