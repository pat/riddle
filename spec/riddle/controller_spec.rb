require 'spec_helper'

describe Riddle::Controller do
  describe '#sphinx_version' do
    before :each do
      @controller = Riddle::Controller.new stub('controller'), 'sphinx.conf'
    end
    
    it "should return 1.10 if using 1.10-beta" do
      @controller.stub!(:` => 'Sphinx 1.10-beta (r2420)')
      @controller.sphinx_version.should == '1.10-beta'
    end
    
    it "should return 0.9.9 if using 0.9.9" do
      @controller.stub!(:` => 'Sphinx 0.9.9-release (r2117)')
      @controller.sphinx_version.should == '0.9.9'
    end
    
    it "should return 0.9.9 if using 0.9.9 rc2" do
      @controller.stub!(:` => 'Sphinx 0.9.9-rc2 (r1785)')
      @controller.sphinx_version.should == '0.9.9'
    end
    
    it "should return 0.9.9 if using 0.9.9 rc1" do
      @controller.stub!(:` => 'Sphinx 0.9.9-rc1 (r1566)')
      @controller.sphinx_version.should == '0.9.9'
    end
    
    it "should return 0.9.8 if using 0.9.8.1" do
      @controller.stub!(:` => 'Sphinx 0.9.8.1-release (r1533)')
      @controller.sphinx_version.should == '0.9.8'
    end
    
    it "should return 0.9.8 if using 0.9.8" do
      @controller.stub!(:` => 'Sphinx 0.9.8-release (r1371)')
      @controller.sphinx_version.should == '0.9.8'
    end
  end
end
