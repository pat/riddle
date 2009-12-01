require 'spec/spec_helper'

describe Riddle::Configuration do
  describe '#initialize' do
    it "should check the loaded Sphinx version" do
      Riddle.should_receive(:version_warning)
      
      Riddle::Configuration.new
    end
  end
end
