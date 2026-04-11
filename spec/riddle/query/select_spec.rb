# frozen_string_literal: true

require 'spec_helper'
require 'date'
require 'time'

describe Riddle::Query::Select do
  let(:query) { Riddle::Query::Select.new }

  it 'handles basic queries on a specific index' do
    expect(query.from('foo_core').to_sql).to eq('SELECT * FROM foo_core')
  end

  it 'handles queries on multiple indices' do
    expect(query.from('foo_core').from('foo_delta').to_sql).
      to eq('SELECT * FROM foo_core, foo_delta')
  end

  it 'accepts multiple arguments for indices' do
    expect(query.from('foo_core', 'foo_delta').to_sql).
      to eq('SELECT * FROM foo_core, foo_delta')
  end

  it "handles custom select values" do
    expect(query.values('@weight').from('foo_core').to_sql).
      to eq('SELECT @weight FROM foo_core')
  end

  it 'handles JSON as a select value using dot notation' do
    expect(query.values('key1.key2.key3').from('foo_core').to_sql).
      to eq('SELECT key1.key2.key3 FROM foo_core')
  end

  it 'handles JSON as a select value using bracket notation 2' do
    expect(query.values("key1['key2']['key3']").from('foo_core').to_sql).
        to eq("SELECT key1['key2']['key3'] FROM foo_core")
  end

  it "can prepend select values" do
    expect(query.values('@weight').prepend_values('foo').from('foo_core').to_sql).
      to eq('SELECT foo, @weight FROM foo_core')
  end

  it 'handles basic queries with a search term' do
    expect(query.from('foo_core').matching('foo').to_sql).
      to eq("SELECT * FROM foo_core WHERE MATCH('foo')")
  end

  it "escapes single quotes in the search terms" do
    expect(query.from('foo_core').matching("fo'o").to_sql).
      to eq("SELECT * FROM foo_core WHERE MATCH('fo\\'o')")
  end

  it 'handles filters with integers' do
    expect(query.from('foo_core').matching('foo').where(:bar_id => 10).to_sql).
      to eq("SELECT * FROM foo_core WHERE MATCH('foo') AND `bar_id` = 10")
  end

  it "handles exclusive filters with integers" do
    expect(query.from('foo_core').matching('foo').where_not(:bar_id => 10).to_sql).
      to eq("SELECT * FROM foo_core WHERE MATCH('foo') AND `bar_id` <> 10")
  end

  it "handles filters with true" do
    expect(query.from('foo_core').matching('foo').where(:bar => true).to_sql).
      to eq("SELECT * FROM foo_core WHERE MATCH('foo') AND `bar` = 1")
  end

  it "handles exclusive filters with true" do
    expect(query.from('foo_core').matching('foo').where_not(:bar => true).to_sql).
      to eq("SELECT * FROM foo_core WHERE MATCH('foo') AND `bar` <> 1")
  end

  it "handles filters with false" do
    expect(query.from('foo_core').matching('foo').where(:bar => false).to_sql).
      to eq("SELECT * FROM foo_core WHERE MATCH('foo') AND `bar` = 0")
  end

  it "handles exclusive filters with false" do
    expect(query.from('foo_core').matching('foo').where_not(:bar => false).to_sql).
      to eq("SELECT * FROM foo_core WHERE MATCH('foo') AND `bar` <> 0")
  end

  it "handles filters with arrays" do
    expect(query.from('foo_core').matching('foo').where(:bars => [1, 2]).to_sql).
      to eq("SELECT * FROM foo_core WHERE MATCH('foo') AND `bars` IN (1, 2)")
  end

  it "ignores filters with empty arrays" do
    expect(query.from('foo_core').matching('foo').where(:bars => []).to_sql).
      to eq("SELECT * FROM foo_core WHERE MATCH('foo')")
  end

  it "handles exclusive filters with arrays" do
    expect(query.from('foo_core').matching('foo').where_not(:bars => [1, 2]).to_sql).
      to eq("SELECT * FROM foo_core WHERE MATCH('foo') AND `bars` NOT IN (1, 2)")
  end

  it "ignores exclusive filters with empty arrays" do
    expect(query.from('foo_core').matching('foo').where_not(:bars => []).to_sql).
      to eq("SELECT * FROM foo_core WHERE MATCH('foo')")
  end

  it "handles filters with timestamps" do
    time = Time.now
    expect(query.from('foo_core').matching('foo').where(:created_at => time).to_sql).
      to eq("SELECT * FROM foo_core WHERE MATCH('foo') AND `created_at` = #{time.to_i}")
  end

  it "handles filters with dates" do
    date = Date.new 2014, 1, 1
    expect(query.from('foo_core').matching('foo').where(:created_at => date).to_sql).
      to eq("SELECT * FROM foo_core WHERE MATCH('foo') AND `created_at` = #{Time.utc(2014, 1, 1).to_i}")
  end

  it "handles exclusive filters with timestamps" do
    time = Time.now
    expect(query.from('foo_core').matching('foo').where_not(:created_at => time).
      to_sql).to eq("SELECT * FROM foo_core WHERE MATCH('foo') AND `created_at` <> #{time.to_i}")
  end

  it "handles filters with ranges" do
    expect(query.from('foo_core').matching('foo').where(:bar => 1..5).to_sql).
      to eq("SELECT * FROM foo_core WHERE MATCH('foo') AND `bar` BETWEEN 1 AND 5")
  end

  it "handles filters with strings" do
    expect(query.from('foo_core').where(:bar => 'baz').to_sql).
      to eq("SELECT * FROM foo_core WHERE `bar` = 'baz'")
  end

  it "handles filters expecting matches on all values" do
    expect(query.from('foo_core').where_all(:bars => [1, 2]).to_sql).
      to eq("SELECT * FROM foo_core WHERE `bars` = 1 AND `bars` = 2")
  end

  it "handles filters expecting matches on all combinations of values" do
    expect(query.from('foo_core').where_all(:bars => [[1,2], 3]).to_sql).
      to eq("SELECT * FROM foo_core WHERE `bars` IN (1, 2) AND `bars` = 3")
  end

  it "handles exclusive filters expecting matches on none of the values" do
    expect(query.from('foo_core').where_not_all(:bars => [1, 2]).to_sql).
      to eq("SELECT * FROM foo_core WHERE (`bars` <> 1 OR `bars` <> 2)")
  end

  it 'handles filters on JSON with dot syntax' do
    expect(query.from('foo_core').where('key1.key2.key3' => 10).to_sql).
      to eq("SELECT * FROM foo_core WHERE key1.key2.key3 = 10")
  end

  it 'handles filters on JSON with bracket syntax' do
    expect(query.from('foo_core').where("key1['key2']['key3']" => 10).to_sql).
        to eq("SELECT * FROM foo_core WHERE key1['key2']['key3'] = 10")
  end

  it 'handles grouping' do
    expect(query.from('foo_core').group_by('bar_id').to_sql).
      to eq("SELECT * FROM foo_core GROUP BY `bar_id`")
  end

  it "handles grouping n-best results" do
    expect(query.from('foo_core').group_by('bar_id').group_best(3).to_sql).
      to eq("SELECT * FROM foo_core GROUP 3 BY `bar_id`")
  end

  it 'handles having conditions' do
    expect(query.from('foo_core').group_by('bar_id').having('bar_id > 10').to_sql).
      to eq("SELECT * FROM foo_core GROUP BY `bar_id` HAVING bar_id > 10")
  end

  it 'handles ordering' do
    expect(query.from('foo_core').order_by('bar_id ASC').to_sql).
      to eq('SELECT * FROM foo_core ORDER BY `bar_id` ASC')
  end

  it 'handles ordering when an already escaped column is passed in' do
    expect(query.from('foo_core').order_by('`bar_id` ASC').to_sql).
      to eq('SELECT * FROM foo_core ORDER BY `bar_id` ASC')
  end

  it 'handles ordering when just a symbol is passed in' do
    expect(query.from('foo_core').order_by(:bar_id).to_sql).
      to eq('SELECT * FROM foo_core ORDER BY `bar_id`')
  end

  it 'handles ordering when a computed sphinx variable is passed in' do
    expect(query.from('foo_core').order_by('@weight DESC').to_sql).
      to eq('SELECT * FROM foo_core ORDER BY @weight DESC')
  end

  it "handles ordering when a sphinx function is passed in" do
    expect(query.from('foo_core').order_by('weight() DESC').to_sql).
      to eq('SELECT * FROM foo_core ORDER BY weight() DESC')
  end

  it 'handles group ordering' do
    expect(query.from('foo_core').order_within_group_by('bar_id ASC').to_sql).
      to eq('SELECT * FROM foo_core WITHIN GROUP ORDER BY `bar_id` ASC')
  end

  it 'handles a limit' do
    expect(query.from('foo_core').limit(10).to_sql).
      to eq('SELECT * FROM foo_core LIMIT 10')
  end

  it 'handles an offset' do
    expect(query.from('foo_core').offset(20).to_sql).
      to eq('SELECT * FROM foo_core LIMIT 20, 20')
  end

  it 'handles an option' do
    expect(query.from('foo_core').with_options(:bar => :baz).to_sql).
      to eq('SELECT * FROM foo_core OPTION bar=baz')
  end

  it 'handles multiple options' do
    sql = query.from('foo_core').with_options(:bar => :baz, :qux => :quux).
      to_sql
    expect(sql).to match(/OPTION .*bar=baz/)
    expect(sql).to match(/OPTION .*qux=quux/)
  end

  it "handles options of hashes" do
    expect(query.from('foo_core').with_options(:weights => {:foo => 5}).to_sql).
      to eq('SELECT * FROM foo_core OPTION weights=(foo=5)')
  end
end
