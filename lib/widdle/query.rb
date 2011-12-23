require 'delegate'
require 'mysql2'
require 'logger'

module Widdle::Query
  Error = Mysql2::Error
  
    def self.client
      threaded[:client] ||= connection(options)
    end
    def self.client=(connection)
      threaded[:client] = connection
    end

    def self.threaded
      Thread.current[:widdle] ||= {}
    end

    def self.connection( options={} )
      options[:host] ||= self.options[:host] || '127.0.0.1'
      options[:port] ||= self.options[:port] || 9312
      Client.new( self.options.merge( options ) )
    end

    def self.options
      threaded[:options] ||= {}
    end

    def self.connect( options={} )
      threaded[:options] = options
    end

    def self.disconnect!
      if threaded[:client]
        client.close
        self.client = nil
      end
    end

    def self.reconnect!
      disconnect!
      connect( options )
    end
    
    def self.active?
      client && client.ping
    end

    class Client < Mysql2::Client
      attr :options, :logger
      @@default_logger = nil

      def self.default_logger
        @@default_logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDERR)
      end
      
      # create a mysql2 connection to sphinx, passing through the connect options
      def initialize(options={})
        @logger = options.delete(:logger) || self.class.default_logger
        @options = options
        options.host = '127.0.0.1' if options.host.nil? || options.host == 'localhost'
        options.port ||= 9312

        # If you use localhost, MySQL insists on a socket connection, but Sphinx
        # requires a TCP connection. Using 127.0.0.1 fixes that.
        # so does passing in the socket file e.g. socket:'/usr/local/sphinx/var/run/sphinx.sock'
        # nb: sphinx.conf listen definition must specify mysql41 as the protocol, e.g.,
        #     listen = localhost:9312:mysql41

        super( { symbolize_keys: true, database_timezone: :utc, application_timezone: :local }.merge( options ) )
      end

      def active?
        ping
      end
      
      alias_method :_query, :query
      def query(*args)
        q = args.shift.to_s
        logger.debug("Widdle.query: #{q}")
        try_query(q,*args)
      end

      def escape( arg )
        String === arg ? super : arg
      end
      
      def meta
        query('SHOW META')
      end

      def warnings
        query('SHOW WARNINGS')
      end
      
      def status
        query('SHOW STATUS')
      end
      
      def tables
        query('SHOW TABLES')
      end
      
      def variables
        query('SHOW VARIABLES')
      end
      
      def collation
        query('SHOW COLLATION')
      end
      
      def describe(index)
        "DESCRIBE #{index}"
      end
      
      def begin
        query('BEGIN')
      end
      
      def commit
        query('COMMIT')
      end
      
      def rollback
        query('ROLLBACK')
      end
      
      def select(*args)
        Select.new(self, *args)
      end
      
      def insert(*args)
        Insert.new(self, *args)
      end

      def replace(*args)
        Insert.new(self, *args).replace!
      end

      def delete(index, *ids)
        query("DELETE FROM #{index} WHERE id IN (#{ids.flatten.join(', ')})")
      end

      def update(index, id, values = {})
        values = values.keys.collect { |key|
          "#{key} = #{values[key]}"
        }.join(', ')
        
        query("UPDATE #{index} SET #{values} WHERE id = #{id}")
      end

      def set(variable, values, global = true)
        values = "(#{values.join(', ')})" if values.is_a?(Array)
        query("SET#{ ' GLOBAL' if global } #{variable} = #{values}")
      end
      
      def snippets(data, index, query, options = nil)
        options = ', ' + options.keys.collect { |key|
          "#{options[key]} AS #{key}"
        }.join(', ') unless options.nil?
        
        query("CALL SNIPPETS('#{data}', '#{index}', '#{query}'#{options})")
      end
      
      def create_function(name, type, file)
        type = type.to_s.upcase
        query("CREATE FUNCTION #{name} RETURNS #{type} SONAME '#{file}'")
      end
      
      def drop_function(name)
        query("DROP FUNCTION #{name}")
      end

     protected

      def try_query(q,*args)
        # fix the scope...connection pool?
        client = self
        tries = 3
        begin
          client._query(q, *args) #super
        rescue Mysql2::Error => e
          if e.message =~ /server has gone away|closed MySQL connection/ && ( tries -= 1 ) > 0
            Widdle::Query.reconnect! unless active?
            client = Widdle::Query.client
            logger.debug( "Widdle#try_query: reconnect: #{e.message}" )
            retry
          end
          raise
        end
      end
    end

    class Result < DelegateClass(Mysql2::Result)
      attr :client
      def initialize(client, *args)
        @client = client
        super(nil) # no result delegate until we run the query
      end
      
      def result(*args)
        __setobj__( __getobj__ || client.query(to_s, *args) )
      end
      
      def each(*args)
        result; super
      end
      
      # fetch the results 
      [ :to_a, :fields, :entries, :count, :size ].each do |method|
        define_method(method) { result; super() }
      end
    end
end

require 'widdle/query/insert'
require 'widdle/query/select'
