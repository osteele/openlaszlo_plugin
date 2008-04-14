require 'applet_view_helper'
require 'swfobject_view_helper'
ActionView::Helpers::AssetTagHelper.register_javascript_include_default 'swfobject'

begin
  require File.dirname(__FILE__) + '/install'
rescue
  raise $! unless RAILS_ENV == 'production'
end
