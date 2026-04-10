# frozen_string_literal: true

require 'spec_helper'

describe "Riddle" do
  it "should escape characters correctly" do
    invalid_chars = ['(', ')', '|', '-', '!', '@', '~', '"', '/']
    invalid_chars.each do |char|
      base = "string with '#{char}' character"
      expect(Riddle.escape(base)).to eq(base.gsub(char, "\\#{char}"))
    end
    
    # Not sure why this doesn't work within the loop...
    expect(Riddle.escape("string with & character")).to eq("string with \\& character")
    
    all_chars = invalid_chars.join('') + '&'
    expect(Riddle.escape(all_chars)).to eq("\\(\\)\\|\\-\\!\\@\\~\\\"\\/\\&")
  end
end