# Author:: Oliver Steele
# Copyright:: Copyright (c) 2006 Oliver Steele.  All rights reserved.
# License:: MIT License.

task :update_javascripts => :update_openlaszlo_javascripts

# This is a separate task from :update_javascripts so that :applets can
# depend just on this one.
task :update_openlaszlo_javascripts do
  sources = Dir[File.expand_path(File.join(File.dirname(__FILE__), '../javascripts/*.js'))]
  target_dir = File.join(RAILS_ROOT, 'public/javascripts')
  # This test is in order to print the update message (via cp) exactly when
  # something is happening.  The file copy itself isn't worth optimizing.
  if sources.detect {|source| !uptodate? File.join(target_dir, File.basename(source)), source}
    cp sources, target_dir
  end
end
