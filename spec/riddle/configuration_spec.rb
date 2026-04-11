# frozen_string_literal: true

require 'spec_helper'

describe Riddle::Configuration do
  describe Riddle::Configuration::Index do
    describe '#settings' do
      it 'should return array with all settings of index' do
        expect(Riddle::Configuration::Index.settings).not_to be_empty
      end

      it 'should return array which contains a docinfo' do
        expect(Riddle::Configuration::Index.settings).to be_include :docinfo
      end
    end
  end

  describe 'class inherited from Riddle::Configuration::Index' do
    before :all do
      class TestIndex < Riddle::Configuration::Index; end
    end
   
    describe '#settings' do
      it 'should has same settings as Riddle::Configuration::Index' do
        expect(TestIndex.settings).to eq(Riddle::Configuration::Index.settings)
      end
    end

  end
end
