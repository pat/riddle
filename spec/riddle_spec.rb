# frozen_string_literal: true

require 'spec_helper'

describe Riddle do
  describe '.version_warning' do
    before :each do
      @existing_version = Riddle.loaded_version
    end
    
    after :each do
      Riddle.loaded_version = @existing_version
    end
    
    it "should do nothing if there is a Sphinx version loaded" do
      expect(STDERR).not_to receive(:puts)
      
      Riddle.loaded_version = '0.9.8'
      Riddle.version_warning
    end
    
    it "should output a warning if no version is loaded" do
      expect(STDERR).to receive(:puts)
      
      Riddle.loaded_version = nil
      Riddle.version_warning
    end
  end
end
