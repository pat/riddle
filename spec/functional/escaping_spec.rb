# frozen_string_literal: true

require 'spec_helper'

describe 'SphinxQL escaping', :live => true do
  let(:connection) { Riddle::SQLClient.connection '127.0.0.1', 9306 }

  def sphinxql_matching(string)
    select = Riddle::Query::Select.new
    select.from 'people'
    select.matching string
    select.to_sql
  end

  ['@', "'", '"', '\\"', "\\'", "?"].each do |string|
    it "escapes #{string}" do
      expect {
        connection.query sphinxql_matching(Riddle::Query.escape(string))
      }.not_to raise_error
    end
  end

  context 'on snippets' do
    def snippets_for(text, words = '', options = nil)
      snippets_query = Riddle::Query.snippets(text, 'people', words, options)

      connection.query(snippets_query).first['snippet']
    end

    it 'preserves original text with special SphinxQL escape characters' do
      text = 'email: john@example.com (yay!)'
      expect(snippets_for(text)).to eq(text)
    end

    it 'preserves original text with special MySQL escape characters' do
      text = "'Dear' Susie\nAlways use {\\LaTeX}"
      expect(snippets_for(text)).to eq(text)
    end

    it 'escapes match delimiters with special SphinxQL escape characters' do
      snippets = snippets_for('hello world', 'world',
        :before_match => '()|-!', :after_match => '@~"/^$')
      expect(snippets).to eq('hello ()|-!world@~"/^$')
    end

    it 'escapes match delimiters with special MySQL escape characters' do
      snippets = snippets_for('hello world', 'world',
        :before_match => "'\"", :after_match => "\n\t\\")
      expect(snippets).to eq("hello '\"world\n\t\\")
    end
  end
end unless RUBY_PLATFORM == 'java' || Riddle.loaded_version.to_i < 2
