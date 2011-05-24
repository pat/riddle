require 'spec_helper'

describe Riddle::Query::Delete do
  it 'handles a single id' do
    query = Riddle::Query::Delete.new 'foo_core', 5
    query.to_sql.should == 'DELETE FROM foo_core WHERE id = 5'
  end
  
  it 'handles multiple ids' do
    query = Riddle::Query::Delete.new 'foo_core', 5, 6, 7
    query.to_sql.should == 'DELETE FROM foo_core WHERE id IN (5, 6, 7)'
  end
  
  it 'handles multiple ids in an explicit array' do
    query = Riddle::Query::Delete.new 'foo_core', [5, 6, 7]
    query.to_sql.should == 'DELETE FROM foo_core WHERE id IN (5, 6, 7)'
  end
end
