class AppletGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      # Applets, views directories.
      m.directory File.join('app/views', class_path)

      actions.each do |action|
        m.directory File.join('app/applets', action)
        path = File.join 'app/applets', action, "#{action}.lzx"
        m.template 'applet.lzx', path, :assigns => {:path => path}
        
        path = File.join 'app/views', class_path, file_name, "#{action}.rhtml"
        m.template 'view.rhtml', path, :assigns => {:applet => action}
      end
    end
  end
end
