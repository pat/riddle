require 'delegate'
require 'mysql2'
require 'logger'

module Widdle::Query

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
      disconnect!
      threaded[:options] = options
    end

    def self.disconnect!
      if threaded[:client]
        client.close
        client = nil
      end
    end

    def reconnect!
      disconnect!
      connect
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

      def query(*args)
        q = args.shift.to_s
        logger.debug("Widdle.query: #{q}")
        super(q,*args)
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
        query(Insert.new(*args).replace!)
      end

      def delete(index, *ids)
        s = if ids.length > 1
          "DELETE FROM #{@index} WHERE id IN (#{ids.join(', ')})"
        else
          "DELETE FROM #{@index} WHERE id = #{ids.first}"
        end
        query(s)
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

require 'Widdle/query/insert'
require 'Widdle/query/select'
