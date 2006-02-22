# Author:: Oliver Steele, Max Carlson
# Copyright:: Copyright (c) 2006 Oliver Steele, Max Carlson.  All rights reserved.
# License:: MIT License.

require 'extensions'

module ActionController #:nodoc:
  # Provides methods for responding to a REST request for an XML
  # representation of a database schema or a set of database
  # records.
module RestHelper
    # Returns a string XML representation of +records+, e.g.:
    #   <records>
    #     <contact id="1" firstname="Victor" lastname="Laszlo"/>
    #     <contact id="2" firstname="Joe" lastname="Laszlo"/>
    #   </records>
    #
    # Instead of +contact+, the value of +records.xml_tag_name+ is used.
    # The attributes are those returned by +records.xml_attributes+.
    def records_xml records, count
    xm = Builder::XmlMarkup.new
    xm.records(:count => records.length, :totalcount => count) {
      records.map do |record|
          xm.tag!(record.xml_tag_name, record.xml_attributes)
      end
    }
  end
  
    # Returns a string XML representation of the model schema for
    # +klass+, e.g.:
    #   <contact>
    #     <column type="integer" name="id"/>
    #     <column type="string" name="firstname"/>
    #     <column type="string" name="lastname"/>
    #   </contact>
    #
    # Instead of +contact+, the value of +klass.xml_tag_name+ is used.
    # The attributes are those returned by +klass.xml_attributes+.
    def schema_xml klass
    xm = Builder::XmlMarkup.new
      xm.element(:name => klass.xml_tag_name) {
        klass.xml_attributes.map do |name, type|
          xm.column(:name => name.to_s, :type => type.to_s)
      end
    }
    end
  end
end

class RangeList
  # Returns a SQL expression that selects exactly those records whose
  # +id+s are covered by this range list.
  def to_sql_condition
    map_intervals do |first, last|
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
end

ActionController::Base.class_eval do
  include ActionController::RestHelper
end
