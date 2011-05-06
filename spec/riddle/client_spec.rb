require 'spec_helper'

describe Riddle::Client do
  describe '#initialize' do
    it "should check the loaded Sphinx version" do
      Riddle.should_receive(:version_warning)
      
      Riddle::Client.new
    end
  end
end
