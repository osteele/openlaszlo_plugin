require 'action_view'

module ActionView #:nodoc:
  module Helpers # :nodoc:
    module AppletHelper # :nodoc:
      def self.included(base)
        base.class_eval do
          include InstanceMethods
        end
      end
      
      module InstanceMethods
        # Returns a path to a Flash object.  The +src+ can be supplied as:
        #
        # * a full path, such as "/applets/applet.swf"
        # * a file name such "applet.swf"
        # * a file name without an extension, such as "applet"
        # All of the above are expanded to "/applets/applet.swf"
        def applet_path(source)
          source = source.sub(/\.lzx/, '')
          compute_public_path(source, 'applets', 'swf')
       rescue NoMethodError
          # See the note at
          # ActionView::Helpers::SwfObjectHelper::InstanceMethods#swfobject_path
          javascript_path(source.sub(/\/applets/, '/javascripts')).
            sub(/\/javascripts/, '/applets').
            sub(/\.js$/, '.swf')
        end
        
        # This method is equivalent to swfobject_tag except, that
        # in development mode it will also recompile the applet if it
        # is older than the files in the applet source directory.
        #
        # In addition, if the <code>debug</code> url query parameter
        # is present in the development mode, this method will
        # generate code that includes a version of the applet with the
        # debug flag set, instead.
        def applet_tag(source, options={})
          path = applet_path(source)
          if ENV['RAILS_ENV'] == 'development' and (ENV['OPENLASZLO_PATH'] || ENV['OPENLASZLO_URL'])
            # This `require` is inside the conditional because we
            # don't need this, or the gem that it requires, in
            # production
            require 'openlaszlo_build_support'
            if params.include?('debug')
              options[:id] ||= File.basename(source, '.swf')
              source += '-debug'
              path = swfobject_path(source)
            end
            OpenLaszlo::Rails::update_asset(path)
          end
          swfobject_tag(path, options)
        end
      end
    end
  end
end

ActionView::Base.class_eval do
  include ActionView::Helpers::AppletHelper
end
