module Widdle::Query
  class Select < Result
    attr :client
    def initialize(client, args={})
      @client = client
      @indices               = Array.wrap(args.delete(:from))
      @match                 = Array.wrap(args.delete(:match))
      @wheres                = Array.wrap(args.delete(:where))
      @group_by              = args.delete(:group)
      @order_by              = args.delete(:order)
      @order_within_group_by = args.delete(:group_order)
      @offset                = args.delete(:offset)
      @limit                 = Array.wrap(args.delete(:limit) || 20)
      @options               = args.delete(:options) || {}
    end
  
    def from(*indices)
      @indices += indices
      self
    end
  
    def match(*match)
      @match += match
      self
    end
  
    def where(*filters)
      @wheres += filters
      self
    end
  
    def group(attribute)
      @group_by = attribute
      self
    end
  
    def order(order)
      @order_by = order
      self
    end
  
    def group_order(order)
      @order_within_group_by = order
      self
    end
  
    # limit or [offset,limit]
    def limit(limit=20)
      @limit = Array.wrap(limit)
      self
    end
  
    def offset(offset)
      @offset = offset
      self
    end
  
    def with_options(options = {})
      @options.merge! options
      self
    end
  
    def to_s
      sql = "SELECT * FROM #{ @indices.join(', ') }"
      sql << " WHERE #{ combined_wheres }" if wheres?
      sql << " GROUP BY #{@group_by}"      if !@group_by.nil?
      sql << " ORDER BY #{@order_by}"      if !@order_by.nil?
      unless @order_within_group_by.nil?
        sql << " WITHIN GROUP ORDER BY #{@order_within_group_by}"
      end
      sql << " #{limit_clause}"   unless @limit.nil? && @offset.nil?
      sql << " #{options_clause}" unless @options.empty?
    
      sql
    end
  
    private
  
    def wheres?
      @wheres.presence || @match.presence
    end
  
    def combined_wheres
      [ *@match.map{|v| "MATCH('#{v}')"}, where_clause(@wheres) ].reject(&:empty?).join(' AND ')
    end
  
    # where: [ conditions ]
    # valid forms for conditions:
    #   String with bind values, e.g.: "attr != :val2 AND lat < :lat AND kid NOT IN :kidarray"
    #     bind values are drawn from hash which must be last entry of conditions array
    #   Hash of attributes and values: { attr1: val1, ... }
    #     and remaining keys in Hash not consumed by bind values are processed according to value type:
    #       Array, e.g. id: [1,2,3,4]  =>  id IN [1,2,3,4]
    #       Range, e.g. kine: 3.0..4.0 =>  kine BETWEEN 3.0 and 4.0
    #       numeric, e.g.  class_id: 4 =>  class_id = 4
    #       String with bind values, e.g.  lng: "> :lngval"    =>  lng > 2.8173   (where hash also contains key :lngval)
    def where_clause( conditions )
      binds = conditions.last if Hash === conditions.last
      bound = []  # remember which binds we consumed from options hash
      conditions.map{ |condition|
        if Hash === condition
          condition.map{|k,v|
            next if bound.include?(k)  # skip if previously consumed
            case v
            when Array
              vals = v.map{|val| client.escape(val) }
              "#{k} IN #{vals}"
            when Range
              if v.exclude_end?
                "#{k} >= #{v.min} AND #{k} < #{v.max}"
              else
                "#{k} BETWEEN #{v.min} AND #{v.max}"
              end
            when Fixnum, Float
                "#{k} = #{v}"
            else
              "#{k} #{bind_symbols( v.to_s, binds, bound )}"
            end
          }
        else 
          bind_symbols( condition.to_s, binds, bound )
        end
      }.reject(&:empty?).join(' AND ')
    end
  
    def bind_symbols( s, binds, bound )
      s.gsub(/:([a-zA-Z]\w*)/) do
        match = $1.to_sym
        if binds.include?(match)
          bound << match
          client.escape(binds[match])
        else
          raise ArgumentError.new("missing value for :#{match} in #{s}")
        end
      end
    end
  
    def limit_clause
      @offset ||= @limit.first if @limit.size > 1
      limit = [@offset, @limit.last]
      "LIMIT #{limit.compact.join(', ')}" if limit.any?
    end
  
    def options_clause
      'OPTION ' + @options.map { |k,v| "#{k}=#{v}" }.join(', ')
    end
  end
end