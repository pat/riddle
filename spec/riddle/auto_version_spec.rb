# frozen_string_literal: true

require 'spec_helper'

describe Riddle::AutoVersion do
  describe '.configure' do
    before :each do
      @controller = Riddle::Controller.new double('configuration'), 'sphinx.conf'
      allow(Riddle::Controller).to receive_messages(:new => @controller)

      unless ENV['SPHINX_VERSION'].nil?
        @env_version, ENV['SPHINX_VERSION'] = ENV['SPHINX_VERSION'].dup, nil
      end
    end

    after :each do
      ENV['SPHINX_VERSION'] = @env_version unless @env_version.nil?
    end

    it "should require 0.9.8 if that is the known version" do
      expect(Riddle::AutoVersion).to receive(:require).with('riddle/0.9.8')

      allow(@controller).to receive_messages(:sphinx_version => '0.9.8')
      Riddle::AutoVersion.configure
    end

    it "should require 0.9.9 if that is the known version" do
      expect(Riddle::AutoVersion).to receive(:require).with('riddle/0.9.9')

      allow(@controller).to receive_messages(:sphinx_version => '0.9.9')
      Riddle::AutoVersion.configure
    end

    it "should require 1.10 if that is the known version" do
      expect(Riddle::AutoVersion).to receive(:require).with('riddle/1.10')

      allow(@controller).to receive_messages(:sphinx_version => '1.10-beta')
      Riddle::AutoVersion.configure
    end

    it "should require 1.10 if using 1.10 with 64 bit IDs" do
      expect(Riddle::AutoVersion).to receive(:require).with('riddle/1.10')

      allow(@controller).to receive_messages(:sphinx_version => '1.10-id64-beta')
      Riddle::AutoVersion.configure
    end

    it "should require 2.0.1 if that is the known version" do
      expect(Riddle::AutoVersion).to receive(:require).with('riddle/2.0.1')

      allow(@controller).to receive_messages(:sphinx_version => '2.0.1-beta')
      Riddle::AutoVersion.configure
    end

    it "should require 2.0.1 if 2.0.2-dev is being used" do
      expect(Riddle::AutoVersion).to receive(:require).with('riddle/2.0.1')

      allow(@controller).to receive_messages(:sphinx_version => '2.0.2-dev')
      Riddle::AutoVersion.configure
    end

    it "should require 2.1.0 if 2.0.3 is being used" do
      expect(Riddle::AutoVersion).to receive(:require).with('riddle/2.1.0')

      allow(@controller).to receive_messages(:sphinx_version => '2.0.3-release')
      Riddle::AutoVersion.configure
    end

    it "should require 2.1.0 if 2.0.4 is being used" do
      expect(Riddle::AutoVersion).to receive(:require).with('riddle/2.1.0')

      allow(@controller).to receive_messages(:sphinx_version => '2.0.4-release')
      Riddle::AutoVersion.configure
    end

    it "should require 2.1.0 if 2.0.5 is being used" do
      expect(Riddle::AutoVersion).to receive(:require).with('riddle/2.1.0')

      allow(@controller).to receive_messages(:sphinx_version => '2.0.5-release')
      Riddle::AutoVersion.configure
    end

    it "should require 2.1.0 if 2.2.1 is being used" do
      expect(Riddle::AutoVersion).to receive(:require).with('riddle/2.1.0')

      allow(@controller).to receive_messages(:sphinx_version => '2.2.1-beta')
      Riddle::AutoVersion.configure
    end

    it "should require 2.1.0 if that is the known version" do
      expect(Riddle::AutoVersion).to receive(:require).with('riddle/2.1.0')

      allow(@controller).to receive_messages(:sphinx_version => '2.1.0-dev')
      Riddle::AutoVersion.configure
    end
  end
end
