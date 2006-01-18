# Author:: Oliver Steele
# Copyright:: Copyright (c) 2006 Oliver Steele.  All rights reserved.
# License:: MIT License.

module OpenLaszlo # :nodoc:
  module CoreExtensions # :nodoc:
    class String # :nodoc:
      module Inflections
        # Downcases and replaces spaces and CamelCasing by hyphens, so
        # that "Record Name", "record_name", and "RecordName" all
        # become "record-name".
        def elementize
          return self.underscore.gsub(/_/, '-')
        end
      end
    end
  end
end

class String #:nodoc:
  include OpenLaszlo::CoreExtensions::String::Inflections
end
