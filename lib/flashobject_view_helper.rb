# Author:: Oliver Steele
# Copyright:: Copyright (c) 2006 Oliver Steele.  All rights reserved.
# License:: MIT License.

require 'action_view'

module OpenLaszlo #:nodoc:
  module Helpers # :nodoc:
    module AssetTagHelper
      def self.included(base)
        base.class_eval do
          include InstanceMethods
        end
      end
      module InstanceMethods
        def flashobject_path source
          compute_public_path source, 'applets', 'swf'
        end
        
        def flashobject_tags source, options={}
          path = flashobject_path source
          verify_file_exists = options.fetch(:verify_file_exists, ENV['RAILS_ENV'] == 'development')
          if verify_file_exists and not File.exists? File.join(RAILS_ROOT, 'public', path)
            return "<div><strong>Warning:</strong> The file <code>#{File.join('public', path)}</code> does not exist.  Did you forget to execute <tt>rake applets</tt>?</div>"
          end
          div_id = options[:div_id] || 'flashcontent'
          flash_id = options[:flash_id] || File.basename(source, '.swf')
          width, height = (options[:size]||'100%x100%').scan(/^(\d*%?)x(\d*%?)$/).first
          background_color = options[:background_color] || '#ffffff'
          flash_version = options[:flash_version] || 7
          variables = options.fetch(:variables, {:lzproxied => false})
          parameters = options.fetch(:parameters, {:scale => 'noscale'})
          fallback_html = options[:fallback_html] || %q{<p>Requires the Flash plugin.  If the plugin is already installed, click <a href="?detectflash=false">here</a>.</p>}
          if options.fetch(:check_for_javascript_include, ENV['RAILS_ENV'] == 'development')
            check_for_javascript ="if (typeof FlashObject == 'undefined') document.getElementById('#{div_id}').innerHTML = '<strong>Warning:</strong> FlashObject is undefined.  Did you forget to execute <tt>rake update_javascripts</tt>, or to include <tt>&lt;%= javascript_include_tag :defaults %></tt> in your view file?';"
          end
          return <<-"EOF"
          <div id="#{div_id}" style="height: #{height}">
            #{fallback_html}
          </div>
          <script type="text/javascript">//<![CDATA[
            #{check_for_javascript}
            var fo = new FlashObject("#{path}", "#{flash_id}", "#{width}", "#{height}", "#{flash_version}", "#{background_color}");
          #{parameters.map{|k,v|%Q[fo.addVariable("#{k}", "#{v}");]}.join("\n")}
          #{variables.map{|k,v|%Q[fo.addVariable("#{k}", "#{v}");]}.join("\n")}
          fo.write("#{div_id}");
          //]]>
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
