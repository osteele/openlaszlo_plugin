# Author:: Oliver Steele
# Copyright:: Copyright (c) 2006 Oliver Steele.  All rights reserved.
# License:: MIT License.

module ActiveRecord #:nodoc:
  module RestHelper #:nodoc:
    def self.append_features(base)
      super
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def find_pages range_list, options={}
        records = []
        for first, last in range_list.intervals do
          local_options = {}.update(options)
          local_options[:offset] = first
          local_options[:limit] = last+1-first if last
          records += find :all, local_options
        end
        return records
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include ActiveRecord::RestHelper
end
