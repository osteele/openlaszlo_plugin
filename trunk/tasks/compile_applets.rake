# Author:: Oliver Steele
# Copyright:: Copyright (c) 2006 Oliver Steele.  All rights reserved.
# License:: MIT License.

require 'ropenlaszlo'

# An applet is any LZX file in app/applets/*/*.lzx whose name matches
# one of these, where {dirname} is the name of the directory that
# contains the file.
APPLET_NAMES = %w{main canvas applet application {dirname}}

desc "Recompile any applets in the app/applets directory"
task :applets => :update_openlaszlo_javascripts

FileList[File.join(RAILS_ROOT, 'app/applets/*/*.lzx')].select{ |path|
  APPLET_NAMES.map{|n| n.sub(/^\{dirname\}$/, File.basename(File.dirname(path)))}.
    include? File.basename(path,'.lzx')}.each do |source|
  target = File.join(RAILS_ROOT, 'public/applets',
                     File.basename(source, '.lzx')+'.swf')
  task :applets => target
  file target => source do
    mkdir_p File.dirname(target)
    puts "Compiling #{source} => #{target}" if verbose
    OpenLaszlo::compile source, :output => target
  end
  task :clobber do rm_f target end
end
