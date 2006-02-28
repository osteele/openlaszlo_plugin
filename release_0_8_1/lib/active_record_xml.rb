# Author:: Oliver Steele
# Copyright:: Copyright (c) 2006 Oliver Steele.  All rights reserved.
# License:: MIT License.

module ActiveRecord #:nodoc:
  module XML #:nodoc:
    def self.append_features(base)
      super
      base.extend(ClassMethods)
    end
    
    # Returns the name of the XML tag that is used to serialize this
    # record into XML.
    def xml_tag_name
      self.class.xml_tag_name
    end
    
    # Returns the names and values of the columns that are
    # included in the XML serialization of this record,
    # including +id+.
    # Type: {Symbol => Object}
    def xml_attributes
      Hash[*self.class.xml_attributes.keys.map {|s| [s, send(s)]}.flatten]
    end
    
    # Provides methods for responding to a REST request for XML.
    module ClassMethods
      # Returns the name of the XML tag that is used to serialize the
      # model schema for this class.
      def xml_tag_name
        name.singularize.elementize
      end
      
      # Returns the names and types of the columns that are
      # included in the XML serialization of this record.
      # Type: {Symbol => String}
      def xml_attributes
        Hash[*content_columns.map {|c| [c.name.intern, c.type || :string]}.flatten].
            update({:id => :integer})
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include ActiveRecord::XML
end
