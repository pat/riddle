require 'spec_helper'

describe "Riddle" do
  it "should escape characters correctly" do
    invalid_chars = ['(', ')', '|', '-', '!', '@', '~', '"', '/']
    invalid_chars.each do |char|
      base = "string with '#{char}' character"
      Riddle.escape(base).should == base.gsub(char, "\\#{char}")
    end
    
    # Not sure why this doesn't work within the loop...
    Riddle.escape("string with & character").should == "string with \\& character"
    
    all_chars = invalid_chars.join('') + '&'
    Riddle.escape(all_chars).should == "\\(\\)\\|\\-\\!\\@\\~\\\"\\/\\&"
  end
end