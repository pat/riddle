module Widdle::Query
  class Insert < Result
    attr :columns, :values
    
    def initialize(client, index, columns = [], values = [])
      @client  = client
      @index   = index
      
      # insert a tuple as a hash, or array of hashes (assumed to all have same keys)
      if Hash === columns
        @columns = columns.keys
        @values = [columns.values]
      elsif Hash === columns.first
        @columns = columns.first.keys
        @values = columns
      else
        @columns = columns
        @values  = values.first.is_a?(Array) ? values : [values]
      end
      @replace = false
#      puts "insert.init: client=#{@client} idx=#{@index} cols=#{@columns}  vals=#{@values}"
    end
    
    def replace!
      @replace = true
      self
    end
    
    def to_s
      "#{command} INTO #{@client.escape(@index)} (#{columns_to_s}) VALUES (#{values_to_s})"
    end

   protected

    def command
      @replace ? 'REPLACE' : 'INSERT'
    end
    
    def columns_to_s
      columns.map{|c| "`#{@client.escape(c)}`" }.join(', ')
    end

    def values_to_s
      values.map { |v|
        if Hash === v
          v.values.map{|v| translated_value(v) }
        else
          v.map{|v| translated_value(v) }
        end.join(', ')
      }.join('), (')
    end

    def translated_value(value)
      case value
      when String, NilClass then "'#{@client.escape(value)}'"
      when TrueClass then 1
      when FalseClass then 0
      else
        value
      end
    end
  end
end
