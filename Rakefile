# Copyright (c) 2006 Oliver Steele <steele@osteele.com>
# All rights reserved.
# 
# This program is free software.
# This file is distributed under an MIT style license.  See
# MIT-LICENSE for details.

require 'rake/rdoctask'

PKG_NAME = "laszlo-plugin"
PKG_VERSION = '0.6.1'
RUBYFORGE_PROJECT = 'laszlo-plugin'
RUBYFORGE_USER = ENV['RUBYFORGE_USER']

desc 'Generate documentation for the plugin.'
Rake::RDocTask.new(:rdoc) do |rd|
  rd.rdoc_dir = 'rdoc'
  rd.options << '--title' << "OpenLaszlo Rails Plugin" <<
    '--main' << 'README'
  rd.rdoc_files.include FileList['lib/*']
  rd.rdoc_files.include ['README', 'CHANGES', 'TODO', 'MIT-LICENSE']
end

task :publish_rdoc do
  sh" scp -r rdoc/* #{RUBYFORGE_USER}@rubyforge.org:/var/www/gforge-projects/#{RUBYFORGE_PROJECT}"
end
