require 'action_view'

module ActionView #:nodoc:
  module Helpers # :nodoc:
    module SwfObjectHelper # :nodoc:
      def self.included(base)
        base.class_eval do
          include InstanceMethods
        end
      end
      
      module InstanceMethods
        # Returns a path to a Flash object.  The +src+ can be supplied as:
        #
        # * a full path, such as "/assets/applet.swf"
        # * a file name such "applet.swf"
        # * a file name without an extension, such as "applet"
        # All of the above are expanded to "/assets/applet.swf"
        def swfobject_path(source)
          compute_public_path(source, 'assets', 'swf')
        rescue NoMethodError
          # Rails 2.2 is missing compute_public_path.  It's present in
          # Rails 2.1 and Rails 2.3.  The right thing to do is to
          # conditionally define SwfObjectTag < AssetTag for Rails
          # 2.2, and return SwfObjectTag.new(self, ???,
          # source).public_path.  Do this instead.
          javascript_path(source.sub(/\/assets/, '/javascripts')).
            sub(/\/javascripts/, '/assets').
            sub(/\.js$/, '.swf').
            sub(/\.swf\.swf$/, 'swf')
        end
        
        # Returns a set of tags that display a Flash object within an
        # HTML page.
        #
        # Options:
        # * <tt>:id</tt> - the +id+ of the element to replace, and of the new Flash object.  Defaults to the base name of the +source+.
        # * <tt>:background_color</tt> - the background color of the Flash object; default white
        # * <tt>:flash_version</tt> - the version of the Flash player that is required; default "8"
        # * <tt>:size</tt> - the size of the Flash object, in the form "100x100".  Defaults to "100%x100%"
        # * <tt>:variables</tt> - a Hash of initialization variables that are passed to the object; default <tt>{:lzproxied => false}</tt>
        # * <tt>:parameters</tt> - a Hash of parameters that configure the display of the object; default <tt>{:scale => 'noscale'}</tt>
        # * <tt>:fallback_html</tt> - HTML text that is displayed when the Flash player is not available.
        #
        # The following options are for developers.  They default to true in
        # development mode, and false otherwise.
        # * <tt>:check_for_javascript_include</tt> - if true, the return value will cause the browser to display a diagnostic message if the SwfObject JavaScript was not included.
        # * <tt>:verify_file_exists</tt> - if true, the return value will cause the browser to display a diagnostic message if the Flash object does not exist.
        def swfobject_tag(source, options={})
          path = swfobject_path(source)
          verify_file_exists = options.fetch(:verify_file_exists, ENV['RAILS_ENV'] == 'development')
          if verify_file_exists and not File.exists?(File.join(RAILS_ROOT, 'public', path).sub(/\?\d+/, ''))
            return "<div><strong>Warning:</strong> The file <code>#{File.join('public', path)}</code> does not exist.  Execute <tt>rake openlaszlo:build:applets</tt> to create it.</div>"
          end
          id = options[:id] || File.basename(source, '.swf')
          width = options[:width] || '100%'
          height = options[:height] || '100%'
          background_color = options[:background_color] || '#ffffff'
          flash_version = options[:flash_version] || '8,0,24,0'
          express_install_url = '/expressInstall.swf'
          variables = options.fetch(:variables, {:lzproxied => false})
          parameters = options.fetch(:parameters, {:scale => 'noscale'})
          fallback_html = options[:fallback_html] || %q{<p>Requires the Flash plugin.  If the plugin is already installed, click <a href="?detectflash=false">here</a>.</p>}
          if options.fetch(:check_for_javascript_include, ENV['RAILS_ENV'] == 'development')
            check_for_javascript = <<-"EOF"
              if (typeof swfobject == 'undefined') document.getElementById('#{id}').innerHTML = '<strong>Warning:</strong> <code>swfobject</code> is undefined.  Did you forget to include <code>&lt;%= javascript_include_tag :defaults %></code> in your view file?';
          EOF
          end
          return(<<-"EOF")
          <div id="#{id}">
            #{fallback_html}
          </div>
          <script type="text/javascript">//<![CDATA[
            #{check_for_javascript}
            swfobject.embedSWF("#{path}", "#{id}", "#{width}", "#{height}", "#{flash_version}", #{express_install_url.to_json}, #{variables.to_json}, #{parameters.to_json});
          //]]>
          </script>
          EOF
        end
      end
    end
  end
end

ActionView::Base.class_eval do
  include ActionView::Helpers::SwfObjectHelper
end
