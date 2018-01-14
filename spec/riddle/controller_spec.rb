# frozen_string_literal: true

require 'spec_helper'

describe Riddle::Controller do
  let(:controller) do
    Riddle::Controller.new double('configuration'), 'sphinx.conf'
  end

  describe '#sphinx_version' do
    it "should return 1.10 if using 1.10-beta" do
      controller.stub(:` => 'Sphinx 1.10-beta (r2420)')
      controller.sphinx_version.should == '1.10-beta'
    end

    it "should return 0.9.9 if using 0.9.9" do
      controller.stub(:` => 'Sphinx 0.9.9-release (r2117)')
      controller.sphinx_version.should == '0.9.9'
    end

    it "should return 0.9.9 if using 0.9.9 rc2" do
      controller.stub(:` => 'Sphinx 0.9.9-rc2 (r1785)')
      controller.sphinx_version.should == '0.9.9'
    end

    it "should return 0.9.9 if using 0.9.9 rc1" do
      controller.stub(:` => 'Sphinx 0.9.9-rc1 (r1566)')
      controller.sphinx_version.should == '0.9.9'
    end

    it "should return 0.9.8 if using 0.9.8.1" do
      controller.stub(:` => 'Sphinx 0.9.8.1-release (r1533)')
      controller.sphinx_version.should == '0.9.8'
    end

    it "should return 0.9.8 if using 0.9.8" do
      controller.stub(:` => 'Sphinx 0.9.8-release (r1371)')
      controller.sphinx_version.should == '0.9.8'
    end
  end

  describe "#merge" do
    before :each do
      allow(Riddle::ExecuteCommand).to receive(:call)
      allow(controller).to receive(:running?).and_return(false)
    end

    it "generates the command" do
      expect(Riddle::ExecuteCommand).to receive(:call).with(
        "indexer --config \"sphinx.conf\" --merge foo bar", nil
      )

      controller.merge "foo", "bar"
    end

    it "passes through the verbose option" do
      expect(Riddle::ExecuteCommand).to receive(:call).with(
        "indexer --config \"sphinx.conf\" --merge foo bar", true
      )

      controller.merge "foo", "bar", :verbose => true
    end

    it "adds filters with range values" do
      expect(Riddle::ExecuteCommand).to receive(:call).with(
        "indexer --config \"sphinx.conf\" --merge foo bar --merge-dst-range flagged 0 1", nil
      )

      controller.merge "foo", "bar", :filters => {:flagged => 0..1}
    end

    it "adds filters with single values" do
      expect(Riddle::ExecuteCommand).to receive(:call).with(
        "indexer --config \"sphinx.conf\" --merge foo bar --merge-dst-range flagged 0 0", nil
      )

      controller.merge "foo", "bar", :filters => {:flagged => 0}
    end

    it "rotates if Sphinx is running" do
      allow(controller).to receive(:running?).and_return(true)

      expect(Riddle::ExecuteCommand).to receive(:call).with(
        "indexer --config \"sphinx.conf\" --merge foo bar --rotate", nil
      )

      controller.merge "foo", "bar"
    end
  end
end
