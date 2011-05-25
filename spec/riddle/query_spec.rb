require 'spec_helper'

describe Riddle::Query do
  describe '.connection' do
    let(:connection) { Riddle::Query.connection 'localhost', 9306 }
    
    it "returns a MySQL Client" do
      connection.should be_a(Mysql2::Client)
    end
    
    it "should handle search requests" do
      connection.query(Riddle::Query.tables).first.should == {
        'Index' => 'people', 'Type' => 'local'
      }
    end
  end
  
  describe '.set' do
    it 'handles a single value' do
      Riddle::Query.set('foo', 'bar').should == 'SET GLOBAL foo = bar'
    end
    
    it 'handles multiple values' do
      Riddle::Query.set('foo', [1, 2, 3]).should == 'SET GLOBAL foo = (1, 2, 3)'
    end
    
    it 'handles non-global settings' do
      Riddle::Query.set('foo', 'bar', false).should == 'SET foo = bar'
    end
  end
  
  describe '.snippets' do
    it 'handles a basic request' do
      Riddle::Query.snippets('foo bar baz', 'foo_core', 'foo').
        should == "CALL SNIPPETS('foo bar baz', 'foo_core', 'foo')"
    end
    
    it 'handles a request with options' do
      Riddle::Query.snippets('foo bar baz', 'foo_core', 'foo', :around => 5).
        should == "CALL SNIPPETS('foo bar baz', 'foo_core', 'foo', 5 AS around)"
    end
  end
  
  describe '.create_function' do
    it 'handles a basic create request' do
      Riddle::Query.create_function('foo', :bigint, 'foo.sh').
        should == "CREATE FUNCTION foo RETURNS BIGINT SONAME 'foo.sh'"
    end
  end
  
  describe '.update' do
    it 'handles a basic update request' do
      Riddle::Query.update('foo_core', 5, :deleted => 1).
        should == 'UPDATE foo_core SET deleted = 1 WHERE id = 5'
    end
  end
end
