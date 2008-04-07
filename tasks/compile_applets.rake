namespace :openlaszlo do
  namespace :build do
    desc "Compile any applets in the app/applets directory"
    task :applets do
      require "#{File.dirname(__FILE__)}/../lib/openlaszlo_build_support"
      OpenLaszlo::Rails.applets.each do |applet|
        puts "Compiling #{applet.source} -> #{applet.target}" if verbose
        applet.compile
      end
    end
  end
  
  namespace :update do
    desc "Recompile any applets in the app/applets directory"
    task :applets do
      require "#{File.dirname(__FILE__)}/../lib/openlaszlo_build_support"
      OpenLaszlo::Rails.applets.each do |applet|
        next if applet.uptodate?
        puts "Compiling #{applet.source} -> #{applet.target}" if verbose
        applet.update
      end
    end
  end
  
  namespace :clobber do
    desc "Clean the applets directory"
    task :applets do
      require "#{File.dirname(__FILE__)}/../lib/openlaszlo_build_support"
      OpenLaszlo::Rails.applets.each do |applet|
        FileUtils.rm_f applet.target
      end
    end
  end
end
