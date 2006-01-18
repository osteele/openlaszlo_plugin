# Author:: Oliver Steele
# Copyright:: Copyright (c) 2006 Oliver Steele.  All rights reserved.
# License:: Ruby License.

require 'action_view'

module OpenLaszlo #:nodoc:
  module Helpers
    module AssetTagHelper
      def self.included(base)
        base.class_eval do
          include InstanceMethods
        end
      end
      module InstanceMethods #:nodoc:
        def flashobject_path source
          compute_public_path source, 'applets', 'swf'
        end
        
        def flashobject_tags source, options={}
          div_id = options[:div_id] || 'flashcontent'
          flash_id = options[:flash_id] || File.basename(source, '.swf')
          width, height = (options[:size]||'100%x100%').scan(/^(\d*%?)x(\d*%?)$/).first
          background_color = options[:background_color] || '#ffffff'
          flash_version = options[:flash_version] || 7
          variables = options.fetch(:variables, {:lzproxied => false})
          parameters = options.fetch(:parameters, {:scale => 'noscale'})
          fallback_html = options[:fallback_html] || %q{<p>Requires the Flash plugin.  If the plugin is already installed, click <a href="?detectflash=false">here</a>.</p>}
          return <<-"EOF"
          <div id="#{div_id}" style="height: #{height}">
            #{fallback_html}
          </div>
          <script type="text/javascript">
            var fo = new FlashObject("#{flashobject_path source}", "#{flash_id}", "#{width}", "#{height}", "#{flash_version}", "#{background_color}");
          #{parameters.map{|k,v|%Q[fo.addVariable("#{k}", "#{v}");]}.join("\n")}
          #{variables.map{|k,v|%Q[fo.addVariable("#{k}", "#{v}");]}.join("\n")}
          fo.write("#{div_id}");
          </script>
EOF
        end
      end
    end
  end
end

ActionView::Base.class_eval do
  include OpenLaszlo::Helpers::AssetTagHelper
end

ActionView::Helpers::AssetTagHelper.register_javascript_include_default 'flashobject'
