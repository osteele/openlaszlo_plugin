namespace :openlaszlo do
  namespace :install do
    desc "Copies the OpenLaszlo javascripts to public/javascripts"
    task :javascripts do
      require "#{File.dirname(__FILE__)}/../lib/openlaszlo_installer"
      puts "Copying files..."
      OpenLaszlo::Rails.install_javascripts
    end
  end
  
  namespace :update do
    desc "Copies the OpenLaszlo javascripts to public/javascripts"
    task :javascripts do
      Rake::Task['openlaszlo:update:javascripts'].invoke
    end
  end
end
