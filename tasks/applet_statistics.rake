task :stats => "openlaszlo:statsetup"

namespace :openlaszlo do
  task :statsetup do
    require "#{File.dirname(__FILE__)}/../lib/applet_statistics"
    STATS_DIRECTORIES += [['Applets', "#{RAILS_ROOT}/app/applets/seatmap"]].select { |_, dir| File.directory?(dir) }
  end
end
