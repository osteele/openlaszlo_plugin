namespace :openlaszlo do
  namespace :build do
    desc "Recompile any applets in the app/applets directory"
    task :applets do
      require "#{File.dirname(__FILE__)}/../lib/openlaszlo_build_support"
      OpenLaszlo::Rails.each_applet do |source, target|
        mkdir_p File.dirname(target)
        puts "Compiling #{source} -> #{target}" if verbose
        OpenLaszlo::compile(source, :output => target)
      end
    end
  end
  
  namespace :clobber do
    desc "Clean the applets directory"
    task :applets do
      require "#{File.dirname(__FILE__)}/../lib/openlaszlo_build_support"
      OpenLaszlo::Rails.each_applet do |_, target|
        FileUtils.rm_f target
      end
    end
  end
end
