# Copyright (c) 2006 Oliver Steele <steele@osteele.com>
# 
# This program is free software.
# You can distribute/modify this program under the same terms as the {OpenLaszlo platform}[http://openlaszlo.org].

# Implements helper functions to implement a subset of the
# spec at http://wiki.openlaszlo.org/Database_Connector.
module RestHelper
  # TODO: order
  def self.records_xml records
    xm = Builder::XmlMarkup.new
    xm.records(:count => records.length) {
      records.map do |record|
        attrs = {:id => record.id}
        for column in record.class.content_columns do
          symbol = column.name.intern
          attrs[symbol] = record.send symbol
        end
        xm.tag!(record.class.name.xmlize, attrs)
      end
    }
  end
  
  def self.schema_xml klass
    xm = Builder::XmlMarkup.new
    xm.element(:name => klass.name.xmlize) {
      klass.content_columns.map do |column|
        xm.column(:name => column.name, :type => column.klass || "String")
      end
    }
  end
end

class String
  def xmlize
    return self.underscore.gsub(/_/, '-')
  end
end
