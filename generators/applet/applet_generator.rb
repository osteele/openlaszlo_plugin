class AppletGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      # Applets, views directories.
      m.directory File.join('app/views', class_path)
      
      # Depend on controller generator but skip if the controller exists.
      m.dependency 'controller', [singular_name], :collision => :skip
      
      actions.each do |action|
        m.directory File.join('app/applets', action)
        path = File.join 'app/applets', action, "#{action}.lzx"
        m.template 'applet.lzx', path, :assigns => { :path => path }
        
        m.directory File.join('app/views', class_path, file_name)
        path = File.join 'app/views', class_path, file_name, "#{action}.html.erb"
        m.template 'view.html.erb', path, :assigns => {:applet => action}

        m.template 'datamanager.lzx', File.join('app/applets', 'datamanager.lzx')
        m.template 'modelcontroller.lzx', File.join('app/applets', 'modelcontroller.lzx')
        m.template 'modelgrid.lzx', File.join('app/applets', 'modelgrid.lzx')
      end
    end
  end
end
