# Author:: Oliver Steele
# Copyright:: Copyright (c) 2006 Oliver Steele.  All rights reserved.
# License:: MIT License.

# A list of intervals -- not Ranges, since the beginning and end of each
# interval may be indeterminate.  This class is used as a helper for the
# the REST XML +records+ and +pages+ actions, which respond to requests
# for lists of ranges of records.
#
# TODO: rename to IntervalList?
class RangeList
  attr_accessor :domain_start, :domain_end
  include Enumerable
  
  private
  # This method is private, since the implementation of a RangeList
  # as an array of pairs is private
  def initialize ranges, options={} #:nodoc:
    @ranges = ranges
    @domain_start = options[:domain_start]
    @domain_end = options[:domain_end]
  end
  
  public
  # Create a RangeList that represents +expr+, where +expr+ is of
  # the form:
  #   1
  #   1-10
  #   1-
  #   -10
  # or a comma-separated sequence of such forms.
  def self.parse expr, options={}
    ranges = []
    for subexpr in expr.split(',') do
      # start, start-, start-end, or -end
      if subexpr =~ /^([0-9]+)?(-([0-9]+)?)?$/
        first = $1 && $1.to_i
        last = $2 ? ($3 && $3.to_i) : first
        ranges << [first, last]
      end
    end
    RangeList.new ranges, options
  end
  
  def empty?
    return @ranges.empty?
  end
  
  def intervals
    @ranges
  end
  
  def map_intervals &block
    @ranges.map do |first, last|
      block.call first, last
    end
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
end
