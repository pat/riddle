# frozen_string_literal: true

require 'spec_helper'

describe "Merging indices", :live => true do
  let(:connection) { Mysql2::Client.new :host => '127.0.0.1', :port => 9306 }
  let(:path)       { "spec/fixtures/sphinx/spec.conf" }
  let(:configuration) do
    Riddle::Configuration::Parser.new(File.read(path)).parse!
  end
  let(:controller) { Riddle::Controller.new configuration, path }
  let(:sphinx)     { Sphinx.new }

  def record_matches?(index, string)
    select = Riddle::Query::Select.new
    select.from index
    select.matching string
    select.to_sql

    !!connection.query(select.to_sql).first
  end

  before :each do
    sphinx.mysql_client.execute "USE riddle"
    sphinx.mysql_client.execute "DELETE FROM articles"
  end

  it "merges in new records" do
    controller.index

    sphinx.mysql_client.execute <<-SQL
    INSERT INTO articles (title, delta) VALUES ('pancakes', 1)
    SQL
    controller.index "article_delta"

    sleep 1.5

    expect(record_matches?("article_delta", "pancakes")).to eq(true)
    expect(record_matches?("article_core", "pancakes")).to eq(false)

    controller.merge "article_core", "article_delta"

    sleep 1.5

    expect(record_matches?("article_core", "pancakes")).to eq(true)
  end

  it "merges in existing records" do
    sphinx.mysql_client.execute <<-SQL
    INSERT INTO articles (title, delta) VALUES ('pancakes', 0)
    SQL
    controller.index

    sleep 1.5

    expect(record_matches?("article_core", "pancakes")).to eq(true)
    expect(record_matches?("article_delta", "pancakes")).to eq(false)

    sphinx.mysql_client.execute <<-SQL
    UPDATE articles SET title = 'waffles', delta = 1 WHERE title = 'pancakes'
    SQL
    controller.index "article_delta"

    sleep 1.5

    expect(record_matches?("article_delta", "waffles")).to eq(true)
    expect(record_matches?("article_core", "waffles")).to eq(false)
    expect(record_matches?("article_core", "pancakes")).to eq(true)

    id = connection.query("SELECT id FROM article_core").first["id"]
    connection.query "UPDATE article_core SET deleted = 1 WHERE id = #{id}"
    expect(
      connection.query("SELECT id FROM article_core WHERE deleted = 1").to_a
    ).to_not be_empty

    controller.merge "article_core", "article_delta",
      :filters => {:deleted => 0}

    sleep 1.5

    expect(record_matches?("article_core", "pancakes")).to eq(false)
    expect(record_matches?("article_core", "waffles")).to eq(true)
    expect(
      connection.query("SELECT id FROM article_core WHERE deleted = 1").to_a
    ).to be_empty
  end
end
