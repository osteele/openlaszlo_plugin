class RestControllerGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, "#{class_name}Controller", "#{class_name}ControllerTest", "#{class_name}Helper"

      # Controller, helper, and test directories.
      m.directory File.join('app/controllers', class_path)
      m.directory File.join('app/helpers', class_path)
      m.directory File.join('test/functional', class_path)
      
      # Controller class, functional test, and helper class.
      m.template 'controller.rb',
                  File.join('app/controllers',
                            class_path,
                            "#{file_name}_controller.rb")

      m.template 'functional_test.rb',
                  File.join('test/functional',
                            class_path,
                            "#{file_name}_controller_test.rb")

      m.template 'helper.rb',
                  File.join('app/helpers',
                            class_path,
                            "#{file_name}_helper.rb")
    end
  end
end
