require 'spec_helper'

describe Riddle::Query::Select do
  let(:query) { Riddle::Query::Select.new }
  
  it 'handles basic queries on a specific index' do
    query.from('foo_core').to_sql.should == 'SELECT * FROM foo_core'
  end
  
  it 'handles queries on multiple indices' do
    query.from('foo_core').from('foo_delta').to_sql.
      should == 'SELECT * FROM foo_core, foo_delta'
  end
  
  it 'accepts multiple arguments for indices' do
    query.from('foo_core', 'foo_delta').to_sql.
      should == 'SELECT * FROM foo_core, foo_delta'
  end
  
  it 'handles basic queries with a search term' do
    query.from('foo_core').matching('foo').to_sql.
      should == "SELECT * FROM foo_core WHERE MATCH('foo')"
  end
  
  it 'handles filters with integers' do
    query.from('foo_core').matching('foo').where(:bar_id => 10).to_sql.
      should == "SELECT * FROM foo_core WHERE MATCH('foo') AND bar_id = 10"
  end
  
  it 'handles grouping' do
    query.from('foo_core').group_by('bar_id').to_sql.
      should == "SELECT * FROM foo_core GROUP BY bar_id"
  end
  
  it 'handles ordering' do
    query.from('foo_core').order_by('bar_id ASC').to_sql.
      should == 'SELECT * FROM foo_core ORDER BY bar_id ASC'
  end
  
  it 'handles group ordering' do
    query.from('foo_core').order_within_group_by('bar_id ASC').to_sql.
      should == 'SELECT * FROM foo_core WITHIN GROUP ORDER BY bar_id ASC'
  end
  
  it 'handles a limit' do
    query.from('foo_core').limit(10).to_sql.
      should == 'SELECT * FROM foo_core LIMIT 10'
  end
  
  it 'handles an offset' do
    query.from('foo_core').offset(20).to_sql.
      should == 'SELECT * FROM foo_core LIMIT 20, 20'
  end
  
  it 'handles an option' do
    query.from('foo_core').with_options(:bar => :baz).to_sql.
      should == 'SELECT * FROM foo_core OPTION bar=baz'
  end
  
  it 'handles multiple options' do
    query.from('foo_core').with_options(:bar => :baz, :qux => :quux).to_sql.
      should == 'SELECT * FROM foo_core OPTION bar=baz, qux=quux'
  end
end
