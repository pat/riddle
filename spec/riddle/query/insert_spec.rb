require 'spec_helper'

describe Riddle::Query::Insert do
  it 'handles inserts' do
    query = Riddle::Query::Insert.new('foo_core', [:id, :deleted], [4, false])
    query.to_sql.should == 'INSERT INTO foo_core (id, deleted) VALUES (4, 0)'
  end
  
  it 'handles replaces' do
    query = Riddle::Query::Insert.new('foo_core', [:id, :deleted], [4, false])
    query.replace!
    query.to_sql.should == 'REPLACE INTO foo_core (id, deleted) VALUES (4, 0)'
  end
  
  it 'encloses strings in single quotes' do
    query = Riddle::Query::Insert.new('foo_core', [:id, :name], [4, 'bar'])
    query.to_sql.should == "INSERT INTO foo_core (id, name) VALUES (4, 'bar')"
  end
  
  it 'handles inserts with more than one set of values' do
    query = Riddle::Query::Insert.new 'foo_core', [:id, :name], [[4, 'bar'], [5, 'baz']]
    query.to_sql.
      should == "INSERT INTO foo_core (id, name) VALUES (4, 'bar'), (5, 'baz')"
  end
end
