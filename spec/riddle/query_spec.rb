# frozen_string_literal: true

require 'spec_helper'

describe Riddle::Query, :live => true do
  describe '.connection' do
    let(:connection) { Riddle::Query.connection 'localhost', 9306 }
    let(:controller) { Riddle::Controller.new nil, '' }

    it "returns a MySQL-compatible client" do
      expect(connection).to be_a(Mysql2::Client).or be_a(Trilogy)
    end

    it "should handle search requests" do
      if controller.sphinx_version.to_i >= 5
        expect(connection.query(Riddle::Query.tables).to_a).to match_array([
          {'Table' => 'people', 'Type' => 'local'},
          {'Table' => 'article_core', 'Type' => 'local'},
          {'Table' => 'article_delta', 'Type' => 'local'}
        ])
      else
        expect(connection.query(Riddle::Query.tables).to_a).to match_array([
          {'Index' => 'people', 'Type' => 'local'},
          {'Index' => 'article_core', 'Type' => 'local'},
          {'Index' => 'article_delta', 'Type' => 'local'}
        ])
      end
    end
  end
end unless RUBY_PLATFORM == 'java' || Riddle.loaded_version.to_i < 2

describe Riddle::Query do
  describe '.set' do
    it 'handles a single value' do
      expect(Riddle::Query.set('foo', 'bar')).to eq('SET GLOBAL foo = bar')
    end

    it 'handles multiple values' do
      expect(Riddle::Query.set('foo', [1, 2, 3])).to eq('SET GLOBAL foo = (1, 2, 3)')
    end

    it 'handles non-global settings' do
      expect(Riddle::Query.set('foo', 'bar', false)).to eq('SET foo = bar')
    end
  end

  describe '.snippets' do
    it 'handles a basic request' do
      expect(Riddle::Query.snippets('foo bar baz', 'foo_core', 'foo')).
        to eq("CALL SNIPPETS('foo bar baz', 'foo_core', 'foo')")
    end

    it 'handles a request with options' do
      expect(Riddle::Query.snippets('foo bar baz', 'foo_core', 'foo', :around => 5)).
        to eq("CALL SNIPPETS('foo bar baz', 'foo_core', 'foo', 5 AS around)")
    end

    it 'handles string options' do
      expect(Riddle::Query.snippets('foo bar baz', 'foo_core', 'foo',
        :before_match => '<strong>')).to eq("CALL SNIPPETS('foo bar baz', 'foo_core', 'foo', '<strong>' AS before_match)")
    end

    it "handles boolean options" do
      expect(Riddle::Query.snippets('foo bar baz', 'foo_core', 'foo',
        :exact_phrase => true)).to eq("CALL SNIPPETS('foo bar baz', 'foo_core', 'foo', 1 AS exact_phrase)")
    end

    it "escapes quotes in the text data" do
      expect(Riddle::Query.snippets("foo bar 'baz", 'foo_core', 'foo')).
        to eq("CALL SNIPPETS('foo bar \\'baz', 'foo_core', 'foo')")
    end

    it "escapes quotes in the query data" do
      expect(Riddle::Query.snippets("foo bar baz", 'foo_core', "foo'")).
        to eq("CALL SNIPPETS('foo bar baz', 'foo_core', 'foo\\'')")
    end
  end

  describe '.create_function' do
    it 'handles a basic create request' do
      expect(Riddle::Query.create_function('foo', :bigint, 'foo.sh')).
        to eq("CREATE FUNCTION foo RETURNS BIGINT SONAME 'foo.sh'")
    end
  end

  describe '.update' do
    it 'handles a basic update request' do
      expect(Riddle::Query.update('foo_core', 5, :deleted => 1)).
        to eq('UPDATE foo_core SET deleted = 1 WHERE id = 5')
    end
  end

  describe '.escape' do
    %w(( ) | - ! @ ~ / ^ $ " > < ?).each do |reserved|
      it "escapes #{reserved}" do
        expect(Riddle::Query.escape(reserved)).to eq("\\#{reserved}")
      end
    end

    it "escapes word-operators correctly" do
      operators = ['MAYBE', 'NEAR', 'PARAGRAPH', 'SENTENCE', 'ZONE', 'ZONESPAN']
      operators.each do |operator|
        base = "string with #{operator} operator"
        expect(Riddle::Query.escape(base)).to eq(base.gsub(operator, "\\#{operator}"))
      end

      expect(Riddle::Query.escape("FIND THE ZONES")).to eq("FIND THE ZONES")
    end
  end
end
