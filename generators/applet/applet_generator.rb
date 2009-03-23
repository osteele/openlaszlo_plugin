class AppletGenerator < Rails::Generator::NamedBase
  attr_reader :applet_name

  def initialize(runtime_args, runtime_options = {})
    # Name argument is required.
    usage if runtime_args.empty?

    @args = runtime_args.dup
    @applet_name = @args.shift
    controller, action = 'controller', 'index'
    case @args.length
    when 0 then
    when 1 then
      @has_controller = true
      controller = actions[0]
    when 2 then
      @has_controller = true
      controller, action = actions
    else usage
    end
    super([controller || 'controller', action], runtime_options)
  end
  
  def has_controller?; @has_controller; end
  def mvc_applet?; false; end

  def manifest
    record do |m|
      # Create the applet
      applet_dir = File.join 'app/applets', applet_name
      applet_main = mvc_applet? ? 'mvc-applet.lzx' : 'applet.lzx'
      js_name = "#{applet_name}.js"
      js_path = File.join applet_dir, js_name
      path = File.join applet_dir, "#{applet_name}.lzx"
      m.directory applet_dir
      m.template applet_main, path, :assigns => { :path => path, :js_path => js_name }
      m.template 'applet.js', js_path

      lib = File.join('app/applets/lib')
      m.directory lib
      m.template 'shared.js', File.join(lib, 'shared.js')
      if mvc_applet?
        m.template 'datamanager.lzx', File.join(lib, 'datamanager.lzx')
        m.template 'modelcontroller.lzx', File.join(lib, 'modelcontroller.lzx')
        m.template 'modelgrid.lzx', File.join(lib, 'modelgrid.lzx')
      end

      if has_controller?
        # Applets, views directories.
        m.directory File.join('app/views', class_path)
        
        # Depend on controller generator but skip if the controller exists.
        m.dependency 'controller', [singular_name], :collision => :skip
        m.directory File.join('app/views', class_path, file_name)
        
        actions.each do |action|
          path = File.join 'app/views', class_path, file_name, "#{action}.html.erb"
          m.template 'view.html.erb', path, :assigns => {:applet => applet_name}
        end
      end
    end
  end

  protected
  def banner
    "Usage: {$0} {spec.name} applet_name [controller [action]]"
  end

#   # from Rails::Generator::NamedBase
#   def assign_names!(name)
#     @name = name
#     base_name, @class_path, @file_path, @class_nesting, @class_nesting_depth = extract_modules(@name)
#     @class_name_without_nesting, @singular_name, @plural_name = inflect_names(base_name)
#     @table_name = (!defined?(ActiveRecord::Base) || ActiveRecord::Base.pluralize_table_names) ? plural_name : singular_name
#     @table_name.gsub! '/', '_'
#     if @class_nesting.empty?
#       @class_name = @class_name_without_nesting
#     else
#       @table_name = @class_nesting.underscore << "_" << @table_name
#       @class_name = "#{@class_nesting}::#{@class_name_without_nesting}"
#     end
#   end

end
