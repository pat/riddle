# frozen_string_literal: true

class Riddle::Query::Select
  def initialize
    @values                = []
    @indices               = []
    @matching              = nil
    @wheres                = {}
    @where_alls            = {}
    @where_nots            = {}
    @where_not_alls        = {}
    @group_by              = nil
    @group_best            = nil
    @having                = []
    @order_by              = nil
    @order_within_group_by = nil
    @offset                = nil
    @limit                 = nil
    @options               = {}
  end

  def values(*values)
    @values += values
    self
  end

  def prepend_values(*values)
    @values.insert 0, *values
    self
  end

  def from(*indices)
    @indices += indices
    self
  end

  def matching(match)
    @matching = match
    self
  end

  def where(filters = {})
    @wheres.merge!(filters)
    self
  end

  def where_all(filters = {})
    @where_alls.merge!(filters)
    self
  end

  def where_not(filters = {})
    @where_nots.merge!(filters)
    self
  end

  def where_not_all(filters = {})
    @where_not_alls.merge!(filters)
    self
  end

  def group_by(attribute)
    @group_by = attribute
    self
  end

  def group_best(count)
    @group_best = count
    self
  end

  def having(*conditions)
    @having += conditions
    self
  end

  def order_by(order)
    @order_by = order
    self
  end

  def order_within_group_by(order)
    @order_within_group_by = order
    self
  end

  def limit(limit)
    @limit = limit
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

  def to_sql
    sql = StringIO.new String.new(""), "w"
    sql << "SELECT #{ extended_values } FROM #{ @indices.join(', ') }"
    sql << " WHERE #{ combined_wheres }" if wheres?
    sql << " #{group_prefix} #{escape_columns(@group_by)}" if !@group_by.nil?
    unless @order_within_group_by.nil?
      sql << " WITHIN GROUP ORDER BY #{escape_columns(@order_within_group_by)}"
    end
    sql << " HAVING #{@having.join(' AND ')}" unless @having.empty?
    sql << " ORDER BY #{escape_columns(@order_by)}" if !@order_by.nil?
    sql << " #{limit_clause}"   unless @limit.nil? && @offset.nil?
    sql << " #{options_clause}" unless @options.empty?

    sql.string
  end

  private

  def extended_values
    @values.empty? ? '*' : @values.join(', ')
  end

  def group_prefix
    ['GROUP', @group_best, 'BY'].compact.join(' ')
  end

  def wheres?
    !(@wheres.empty? && @where_alls.empty? && @where_nots.empty? && @where_not_alls.empty? && @matching.nil?)
  end

  def combined_wheres
    wheres = wheres_to_s

    if @matching.nil?
      wheres
    elsif wheres.empty?
      "MATCH(#{Riddle::Query.quote @matching})"
    else
      "MATCH(#{Riddle::Query.quote @matching}) AND #{wheres}"
    end
  end

  def wheres_to_s
    (
      @wheres.keys.collect { |key|
        filter_comparison_and_value key, @wheres[key]
      } +
      @where_alls.collect { |key, values|
        values.collect { |value|
          filter_comparison_and_value key, value
        }
      } +
      @where_nots.keys.collect { |key|
        exclusive_filter_comparison_and_value key, @where_nots[key]
      } +
      @where_not_alls.collect { |key, values|
        '(' + values.collect { |value|
          exclusive_filter_comparison_and_value key, value
        }.join(' OR ') + ')'
      }
    ).flatten.compact.join(' AND ')
  end

  def filter_comparison_and_value(attribute, value)
    case value
    when Array
      if !value.flatten.empty?
        "#{escape_column(attribute)} IN (#{value.collect { |val| filter_value(val) }.join(', ')})"
      end
    when Range
      "#{escape_column(attribute)} BETWEEN #{filter_value(value.first)} AND #{filter_value(value.last)}"
    else
      "#{escape_column(attribute)} = #{filter_value(value)}"
    end
  end

  def exclusive_filter_comparison_and_value(attribute, value)
    case value
    when Array
      if !value.flatten.empty?
        "#{escape_column(attribute)} NOT IN (#{value.collect { |val| filter_value(val) }.join(', ')})"
      end
    when Range
      "#{escape_column(attribute)} < #{filter_value(value.first)} OR #{attribute} > #{filter_value(value.last)}"
    else
      "#{escape_column(attribute)} <> #{filter_value(value)}"
    end
  end

  def filter_value(value)
    case value
    when TrueClass
      1
    when FalseClass
      0
    when Time
      value.to_i
    when Date
      Time.utc(value.year, value.month, value.day).to_i
    when String
      "'#{value.gsub("'", "\\'")}'"
    else
      value
    end
  end

  def limit_clause
    if @offset.nil?
      "LIMIT #{@limit}"
    else
      "LIMIT #{@offset}, #{@limit || 20}"
    end
  end

  def options_clause
    'OPTION ' + @options.keys.collect { |key|
      "#{key}=#{option_value @options[key]}"
    }.join(', ')
  end

  def option_value(value)
    case value
    when Hash
      '(' + value.collect { |key, value| "#{key}=#{value}" }.join(', ') + ')'
    else
      value
    end
  end

  def escape_column(column)
    if column.to_s[/\A[`@]/] || column.to_s[/\A\w+\(/] || column.to_s[/\A\w+[.\[]/]
      column
    else
      column_name, *extra = column.to_s.split(' ')
      extra.unshift("`#{column_name}`").compact.join(' ')
    end
  end

  def escape_columns(columns)
    columns.to_s.split(/,\s*/).collect { |column|
      escape_column(column)
    }.join(', ')
  end
end
