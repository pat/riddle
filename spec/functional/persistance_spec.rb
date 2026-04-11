# frozen_string_literal: true

require 'spec_helper'

describe "Sphinx Persistance Connection", :live => true do
  before :each do
    @client = Riddle::Client.new("localhost", 9313)
  end
  
  it "should raise errors once already opened" do
    @client.open
    expect { @client.open }.to raise_error('Already Connected')
    @client.close
  end
  
  it "should raise errors if closing when already closed" do
    expect { @client.close }.to raise_error('Not Connected')
  end
end
