require 'spec_helper'

describe 'SphinxQL escaping', :live => true do
  let(:connection) { Mysql2::Client.new :host => '127.0.0.1', :port => 9306 }

  def sphinxql_matching(string)
    "SELECT * FROM people WHERE MATCH('#{string}')"
  end

  ['@', "'", '"', '\\"', "\\'"].each do |string|
    it "escapes #{string}" do
      lambda {
        connection.query sphinxql_matching(Riddle::Query.escape(string))
      }.should_not raise_error(Mysql2::Error)
    end
  end

  context 'on snippets' do
    def snippets_for(text)
      res = connection.query Riddle::Query.snippets(text, 'people', '')
      res.first['snippet']
    end

    it 'preserves original text with special SphinxQL escape characters' do
      text = 'email: john@example.com (yay!)'
      snippets_for(text).should == text
    end

    it 'preserves original text with special MySQL escape characters' do
      text = "'Dear' Susie\nAlways use {\\LaTeX}"
      snippets_for(text).should == text
    end
  end
end unless RUBY_PLATFORM == 'java' || Riddle.loaded_version.to_i < 2
