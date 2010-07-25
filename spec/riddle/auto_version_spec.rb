require 'spec/spec_helper'

describe Riddle::AutoVersion do
  describe '.configure' do
    before :each do
      @controller = Riddle::Controller.new stub('configuration'), 'sphinx.conf'
      Riddle::Controller.stub!(:new => @controller)
    end
    
    it "should require 0.9.8 if that is the known version" do
      Riddle::AutoVersion.should_receive(:require).with('riddle/0.9.8')
      
      @controller.stub!(:sphinx_version => '0.9.8')
      Riddle::AutoVersion.configure
    end
    
    it "should require 0.9.9 if that is the known version" do
      Riddle::AutoVersion.should_receive(:require).with('riddle/0.9.9')
      
      @controller.stub!(:sphinx_version => '0.9.9')
      Riddle::AutoVersion.configure
    end
    
    it "should require 1.10 if that is the known version" do
      Riddle::AutoVersion.should_receive(:require).with('riddle/1.10')
      
      @controller.stub!(:sphinx_version => '1.10-beta')
      Riddle::AutoVersion.configure
    end
  end
end
