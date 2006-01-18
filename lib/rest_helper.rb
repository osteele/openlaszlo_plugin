# Author:: Oliver Steele
# Copyright:: Copyright (c) 2006 Oliver Steele.  All rights reserved.
# License:: MIT License.

require 'range_list'
require 'extensions'

# Implements helper functions to implement a subset of the
# spec at http://wiki.openlaszlo.org/Database_Connector.
module RestHelper
  def self.records_xml records
    xm = Builder::XmlMarkup.new
    xm.records(:count => records.length) {
      records.map do |record|
        attrs = {:id => record.id}
        for column in record.class.content_columns do
          symbol = column.name.intern
          attrs[symbol] = record.send symbol
        end
        xm.tag!(record.class.name.singularize.elementize, attrs)
      end
    }
  end
  
  def self.schema_xml klass
    xm = Builder::XmlMarkup.new
    xm.element(:name => klass.name.singularize.elementize) {
      klass.content_columns.map do |column|
        xm.column(:name => column.name, :type => column.klass || "String")
      end
    }
  end
end
