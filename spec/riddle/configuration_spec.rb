require 'spec_helper'

describe Riddle::Configuration do
  describe Riddle::Configuration::Index do
    describe '#settings' do
      it 'should return array with all settings of index' do
        Riddle::Configuration::Index.settings.should_not be_empty
      end

      it 'should return array which contains a docinfo' do
        Riddle::Configuration::Index.settings.should be_include :docinfo
      end
    end
  end

  describe 'class inherited from Riddle::Configuration::Index' do
    before :all do
      class TestIndex < Riddle::Configuration::Index; end
    end
   
    describe '#settings' do
      it 'should has same settings as Riddle::Configuration::Index' do
        TestIndex.settings.should == Riddle::Configuration::Index.settings
      end
    end

  end
end
