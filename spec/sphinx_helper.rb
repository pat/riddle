require 'erb'
require 'yaml'

class SphinxHelper
  attr_accessor :host, :username, :password
  attr_reader   :path
  
  def initialize
    @host     = "localhost"
    @username = "anonymous"
    @password = ""

    if File.exist?("spec/fixtures/sql/conf.yml")
      config    = YAML.load(File.open("spec/fixtures/sql/conf.yml"))
      @host     = config["host"]
      @username = config["username"]
      @password = config["password"]
    end
    
    @path = File.expand_path(File.dirname(__FILE__))
  end
  
  def setup_mysql
    client = Mysql2::Client.new(
      :host => @host,
      :username => @username,
      :password => @password
    )

    databases = client.query('SHOW DATABASES', :as => :array).to_a.flatten
    unless databases.include?('riddle')
      client.query 'CREATE DATABASE riddle'
    end

    client.query "USE riddle"
    
    structure = File.open("spec/fixtures/sql/structure.sql") { |f| f.read }
    structure.split(/;/).each { |sql| client.query sql }
    client.query <<-SQL
      LOAD DATA LOCAL INFILE '#{@path}/fixtures/sql/data.tsv' INTO TABLE
      `riddle`.`people` FIELDS TERMINATED BY ',' ENCLOSED BY "'" (gender,
      first_name, middle_initial, last_name, street_address, city, state,
      postcode, email, birthday)
    SQL

    client.close
  end
  
  def reset
    setup_mysql
    index
  end
  
  def generate_configuration
    template = File.open("spec/fixtures/sphinx/configuration.erb") { |f| f.read }
    File.open("spec/fixtures/sphinx/spec.conf", "w") { |f|
      f.puts ERB.new(template).result(binding)
    }
  end
  
  def index
    cmd = "indexer --config #{@path}/fixtures/sphinx/spec.conf --all"
    cmd << " --rotate" if running?
    `#{cmd}`
  end
  
  def start
    return if running?

    cmd = "searchd --config #{@path}/fixtures/sphinx/spec.conf"
    `#{cmd}`

    sleep(1)

    unless running?
      puts "Failed to start searchd daemon. Check fixtures/sphinx/searchd.log."
    end
  end
  
  def stop
    return unless running?
    `kill #{pid}`
  end
  
  def pid
    if File.exists?("#{@path}/fixtures/sphinx/searchd.pid")
      `cat #{@path}/fixtures/sphinx/searchd.pid`[/\d+/]
    else
      nil
    end
  end

  def running?
    pid && `ps #{pid} | wc -l`.to_i > 1
  end
end
