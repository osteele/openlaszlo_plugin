# Author:: Oliver Steele
# Copyright:: Copyright (c) 2006 Oliver Steele.  All rights reserved.
# License:: Ruby License.

class RangeList
  attr_accessor :domain_start, :domain_end
  include Enumerable
  
  private
  # private, since the implementation of a RangeList as an array of
  # pairs is private
  def initialize ranges, attributes
    @ranges = ranges
    @domain_start = attributes[:domain_start]
    @domain_end = attributes[:domain_end]
  end
  
  public
  def self.parse expr, attributes={}
    ranges = []
    for subexpr in expr.split(',') do
      # start, start-, start-end, or -end
      if subexpr =~ /^([0-9]+)?(-([0-9]+)?)?$/
        first = $1 && $1.to_i
        last = $2 ? ($3 && $3.to_i) : first
        ranges << [first, last]
      end
    end
    RangeList.new ranges, attributes
  end
  
  def empty?
    return @ranges.empty?
  end
  
  def each_range &block
    for first, last in @ranges do
      first ||= @domain_start
      last ||= @domain_end
      raise "Can't enumerate a #{self.class} without a start index or domain start" unless first
      raise "Can't enumerate a #{self.class} without a without an end index or domain end" unless last
      block.call(first..last)
    end
  end
  
  def each &block
    self.each_range do |range|
      range.each &block
    end
  end
  
  alias :to_a :collect
  
  def to_sql_condition
    @ranges.map do |first, last|
      if first == last
        "id=#{first}"
      else
        conjuncts = []
        conjuncts << "#{first}<=id" if first
        conjuncts << "id<=#{last}" if last
        conjuncts.length > 1 ? '(' + conjuncts.join(' AND ') + ')' : conjuncts.first
      end
    end.join(' OR ')
  end
  
  def pages_for klass
    records = []
    for first, last in @ranges do
      options = {}
      options[:offset] = first
      options[:limit] = last+1-first if last
      records += klass.find :all, options
    end
    return records
  end
end
