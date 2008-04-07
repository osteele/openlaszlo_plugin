task :notes => "openlaszlo:notessetup"

namespace :openlaszlo do
  task :notessetup do
    require "#{File.dirname(__FILE__)}/../lib/applet_annotation_extractor"
  end
end
