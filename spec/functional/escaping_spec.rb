require 'spec_helper'

describe 'SphinxQL escaping', :live => true do
  let(:connection) { Mysql2::Client.new :host => '127.0.0.1', :port => 9306 }

  def sphinxql_matching(string)
    select = Riddle::Query::Select.new
    select.from 'people'
    select.matching string
    select.to_sql
  end

  ['@', "'", '"', '\\"', "\\'"].each do |string|
    it "escapes #{string}" do
      lambda {
        connection.query sphinxql_matching(Riddle::Query.escape(string))
      }.should_not raise_error(Mysql2::Error)
    end
  end

  context 'on snippets' do
    def snippets_for(text, words = '', options = nil)
      snippets_query = Riddle::Query.snippets(text, 'people', words, options)
      connection.query(snippets_query).first['snippet']
    end

    it 'preserves original text with special SphinxQL escape characters' do
      text = 'email: john@example.com (yay!)'
      snippets_for(text).should == text
    end

    it 'preserves original text with special MySQL escape characters' do
      text = "'Dear' Susie\nAlways use {\\LaTeX}"
      snippets_for(text).should == text
    end

    it 'escapes match delimiters with special SphinxQL escape characters' do
      snippets = snippets_for('hello world', 'world',
        :before_match => '()|-!', :after_match => '@~"/^$')
      snippets.should == 'hello ()|-!world@~"/^$'
    end

    it 'escapes match delimiters with special MySQL escape characters' do
      snippets = snippets_for('hello world', 'world',
        :before_match => "'\"", :after_match => "\n\t\\")
      snippets.should == "hello '\"world\n\t\\"
    end
  end
end unless RUBY_PLATFORM == 'java' || Riddle.loaded_version.to_i < 2
