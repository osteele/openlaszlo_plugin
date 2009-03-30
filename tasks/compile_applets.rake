namespace :openlaszlo do
  namespace :create do
    desc "Create a symlink from OPENLASZLO_HOME to app/applets, for faster compilation"
    task :symlinks do
      require 'openlaszlo/utils'
      target = OpenLaszlo::symlink_to 'app/applets', "#{File.basename(RAILS_ROOT)}.rails"
      puts "Created link at #{target}"
    end
  end

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
