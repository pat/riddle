require 'spec_helper'

describe Riddle::AutoVersion do
  describe '.configure' do
    before :each do
      @controller = Riddle::Controller.new stub('configuration'), 'sphinx.conf'
      Riddle::Controller.stub!(:new => @controller)

      unless ENV['SPHINX_VERSION'].nil?
        @env_version, ENV['SPHINX_VERSION'] = ENV['SPHINX_VERSION'].dup, nil
      end
    end

    after :each do
      ENV['SPHINX_VERSION'] = @env_version unless @env_version.nil?
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

    it "should require 1.10 if using 1.10 with 64 bit IDs" do
      Riddle::AutoVersion.should_receive(:require).with('riddle/1.10')

      @controller.stub!(:sphinx_version => '1.10-id64-beta')
      Riddle::AutoVersion.configure
    end

    it "should require 2.0.1 if that is the known version" do
      Riddle::AutoVersion.should_receive(:require).with('riddle/2.0.1')

      @controller.stub!(:sphinx_version => '2.0.1-beta')
      Riddle::AutoVersion.configure
    end

    it "should require 2.0.1 if 2.0.2-dev is being used" do
      Riddle::AutoVersion.should_receive(:require).with('riddle/2.0.1')

      @controller.stub!(:sphinx_version => '2.0.2-dev')
      Riddle::AutoVersion.configure
    end

    it "should require 2.1.0 if 2.0.3 is being used" do
      Riddle::AutoVersion.should_receive(:require).with('riddle/2.1.0')

      @controller.stub!(:sphinx_version => '2.0.3-release')
      Riddle::AutoVersion.configure
    end

    it "should require 2.1.0 if 2.0.4 is being used" do
      Riddle::AutoVersion.should_receive(:require).with('riddle/2.1.0')

      @controller.stub!(:sphinx_version => '2.0.4-release')
      Riddle::AutoVersion.configure
    end

    it "should require 2.1.0 if 2.0.5 is being used" do
      Riddle::AutoVersion.should_receive(:require).with('riddle/2.1.0')

      @controller.stub!(:sphinx_version => '2.0.5-release')
      Riddle::AutoVersion.configure
    end

    it "should require 2.1.0 if that is the known version" do
      Riddle::AutoVersion.should_receive(:require).with('riddle/2.1.0')

      @controller.stub!(:sphinx_version => '2.1.0-dev')
      Riddle::AutoVersion.configure
    end
  end
end
