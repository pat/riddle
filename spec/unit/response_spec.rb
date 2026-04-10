# frozen_string_literal: true

require 'spec_helper'

describe Riddle::Client::Response do
  it "should interpret an integer correctly" do
    expect(Riddle::Client::Response.new([42].pack('N')).next_int).to eq(42)
  end
  
  it "should interpret a string correctly" do
    str = "this is a string"
    expect(Riddle::Client::Response.new(
      [str.length].pack('N') + str
    ).next).to eq(str)
  end
  
  # Comparing floats with decimal places doesn't seem to be exact
  it "should interpret a float correctly" do
    expect(Riddle::Client::Response.new([1.0].pack('f').unpack('L*').pack('N')).next_float).to eq(1.0)
  end
  
  it "should interpret an array of strings correctly" do
    arr = ["a", "b", "c", "d"]
    expect(Riddle::Client::Response.new(
      [arr.length].pack('N') + arr.collect { |str|
        [str.length].pack('N') + str
      }.join("")
    ).next_array).to eq(arr)
  end
  
  it "should interpret an array of ints correctly" do
    arr = [1, 2, 3, 4]
    expect(Riddle::Client::Response.new(
      [arr.length].pack('N') + arr.collect { |int|
        [int].pack('N')
      }.join("")
    ).next_int_array).to eq(arr)
  end
  
  it "should reflect the length of the incoming data correctly" do
    data = [1, 2, 3, 4].pack('NNNN')
    expect(Riddle::Client::Response.new(data).length).to eq(data.length)
  end
  
  it "should handle a combination of strings and ints correctly" do
    data = [1, 3, 5, 1].pack('NNNN') + 'a' + [2, 4].pack('NN') + 'test'
    response = Riddle::Client::Response.new(data)
    expect(response.next_int).to eq(1)
    expect(response.next_int).to eq(3)
    expect(response.next_int).to eq(5)
    expect(response.next).to eq('a')
    expect(response.next_int).to eq(2)
    expect(response.next).to eq('test')
  end
  
  it "should handle a combination of strings, ints, floats and string arrays correctly" do
    data = [1, 2, 2].pack('NNN') + 'aa' + [2].pack('N') + 'bb' + [4].pack('N') +
      "word" + [7].pack('f').unpack('L*').pack('N') + [3, 2, 2, 2].pack('NNNN')
    response = Riddle::Client::Response.new(data)
    expect(response.next_int).to eq(1)
    expect(response.next_array).to eq(['aa', 'bb'])
    expect(response.next).to eq("word")
    expect(response.next_float).to eq(7)
    expect(response.next_int_array).to eq([2, 2, 2])
  end
end