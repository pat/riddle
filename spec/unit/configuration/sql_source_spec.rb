require 'spec/spec_helper'

describe Riddle::Configuration::SQLSource do
  it "should be invalid without a host, user, database, and query if there's no parent" do
    source = Riddle::Configuration::SQLSource.new("src1", "mysql")
    source.should_not be_valid
    
    source.sql_host   = "localhost"
    source.sql_user   = "test"
    source.sql_db     = "test"
    source.sql_query  = "SELECT * FROM tables"
    source.should be_valid
    
    [:name, :type, :sql_host, :sql_user, :sql_db, :sql_query].each do |setting|
      value = source.send(setting)
      source.send("#{setting}=".to_sym, nil)
      source.should_not be_nil
      source.send("#{setting}=".to_sym, value)
    end
  end
  
  it "should be invalid without only a name and type if there is a parent" do
    source = Riddle::Configuration::SQLSource.new("src1", "mysql")
    source.should_not be_valid

    source.parent = "sqlparent"
    source.should be_valid

    source.name = nil
    source.should_not be_valid

    source.name = "src1"
    source.type = nil
    source.should_not be_valid
  end

  it "should raise a ConfigurationError if rendering when not valid" do
    source = Riddle::Configuration::SQLSource.new("src1", "mysql")
    lambda { source.render }.should raise_error(Riddle::Configuration::ConfigurationError)
  end

  it "should render correctly when valid" do
    source = Riddle::Configuration::SQLSource.new("src1", "mysql")
    source.sql_host = "localhost"
    source.sql_user = "test"
    source.sql_pass = ""
    source.sql_db = "test"
    source.sql_port = 3306
    source.sql_sock = "/tmp/mysql.sock"
    source.mysql_connect_flags = 32
    source.sql_query_pre << "SET NAMES utf8" << "SET SESSION query_cache_type=OFF"
    source.sql_query = "SELECT id, group_id, UNIX_TIMESTAMP(date_added) AS date_added, title, content FROM documents WHERE id >= $start AND id <= $end"
    source.sql_query_range = "SELECT MIN(id), MAX(id) FROM documents"
    source.sql_range_step = 1000
    source.sql_query_killlist = "SELECT id FROM documents WHERE edited>=@last_reindex"
    source.sql_attr_uint << "author_id" << "forum_id:9" << "group_id"
    source.sql_attr_bool << "is_deleted"
    source.sql_attr_bigint << "my_bigint_id"
    source.sql_attr_timestamp << "posted_ts" << "last_edited_ts" << "date_added"
    source.sql_attr_str2ordinal << "author_name"
    source.sql_attr_float << "lat_radians" << "long_radians"
    source.sql_attr_multi << "uint tag from query; select id, tag FROM tags"
    source.sql_query_post = ""
    source.sql_query_post_index = "REPLACE INTO counters (id, val) VALUES ('max_indexed_id', $maxid)"
    source.sql_ranged_throttle = 0
    source.sql_query_info = "SELECT * FROM documents WHERE id = $id"
    source.mssql_winauth = 1
    source.mssql_unicode = 1
    source.unpack_zlib << "zlib_column"
    source.unpack_mysqlcompress << "compressed_column" << "compressed_column_2"
    source.unpack_mysqlcompress_maxsize = "16M"

    source.render.should == <<-SQLSOURCE
source src1
{
  type = mysql
  sql_host = localhost
  sql_user = test
  sql_pass = 
  sql_db = test
  sql_port = 3306
  sql_sock = /tmp/mysql.sock
  mysql_connect_flags = 32
  sql_query_pre = SET NAMES utf8
  sql_query_pre = SET SESSION query_cache_type=OFF
  sql_query = SELECT id, group_id, UNIX_TIMESTAMP(date_added) AS date_added, title, content FROM documents WHERE id >= $start AND id <= $end
  sql_query_range = SELECT MIN(id), MAX(id) FROM documents
  sql_range_step = 1000
  sql_query_killlist = SELECT id FROM documents WHERE edited>=@last_reindex
  sql_attr_uint = author_id
  sql_attr_uint = forum_id:9
  sql_attr_uint = group_id
  sql_attr_bool = is_deleted
  sql_attr_bigint = my_bigint_id
  sql_attr_timestamp = posted_ts
  sql_attr_timestamp = last_edited_ts
  sql_attr_timestamp = date_added
  sql_attr_str2ordinal = author_name
  sql_attr_float = lat_radians
  sql_attr_float = long_radians
  sql_attr_multi = uint tag from query; select id, tag FROM tags
  sql_query_post = 
  sql_query_post_index = REPLACE INTO counters (id, val) VALUES ('max_indexed_id', $maxid)
  sql_ranged_throttle = 0
  sql_query_info = SELECT * FROM documents WHERE id = $id
  mssql_winauth = 1
  mssql_unicode = 1
  unpack_zlib = zlib_column
  unpack_mysqlcompress = compressed_column
  unpack_mysqlcompress = compressed_column_2
  unpack_mysqlcompress_maxsize = 16M
}
    SQLSOURCE
  end
end