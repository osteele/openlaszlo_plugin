# Author:: Oliver Steele
# Copyright:: Copyright (c) 2006 Oliver Steele.  All rights reserved.
# License:: MIT License.

class AppletGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      # Applets, views directories.
      m.directory File.join('app/views', class_path)
      
      # Depend on model generator but skip if the model exists.
      m.dependency 'model', [singular_name], :collision => :skip
      
      # Depend on controller generator but skip if the controller exists.
      m.dependency 'rest_controller', [singular_name], :collision => :skip
      
      actions.each do |action|
        m.directory File.join('app/applets', action)
        path = File.join 'app/applets', action, "#{action}.lzx"
        m.template 'applet.lzx', path, :assigns => {
          :path => path, :element_name => class_name.singularize.elementize}
        
        m.directory File.join('app/views', class_path, file_name)
        path = File.join 'app/views', class_path, file_name, "#{action}.rhtml"
        m.template 'view.rhtml', path, :assigns => {:applet => action}
      end
    end
  end
end
