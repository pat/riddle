# frozen_string_literal: true

class Riddle::Query::Insert
  attr_reader :columns, :values

  def initialize(index, columns = [], values = [])
    @index   = index
    @columns = columns
    @values  = values.first.is_a?(Array) ? values : [values]
    @replace = false
  end

  def replace!
    @replace = true
    self
  end

  def to_sql
    "#{command} INTO #{@index} (#{columns_to_s}) VALUES (#{values_to_s})"
  end

  private

  def command
    @replace ? 'REPLACE' : 'INSERT'
  end

  def columns_to_s
    columns.collect { |column|
      column.to_s == 'id' ? 'id' : "`#{column}`"
    }.join(', ')

  end

  def values_to_s
    values.collect { |value_set|
      value_set.collect { |value|
        value.is_a?(String) ? translated_value(value).dup.force_encoding("UTF-8") : translated_value(value)
      }.join(', ')
    }.join('), (')
  end

  def translated_value(value)
    case value
    when String
      "'#{value.gsub(/['\\]/, '').gsub(/\s+/, ' ')}'"
    when TrueClass, FalseClass
      value ? 1 : 0
    when Time
      value.to_i
    when Date
      value.to_time.to_i
    when Array
      "(#{value.join(',')})"
    else
      value
    end
  end
end
