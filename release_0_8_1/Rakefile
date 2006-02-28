# Copyright (c) 2006 Oliver Steele <steele@osteele.com>
# All rights reserved.
# 
# This program is free software.
# This file is distributed under an MIT style license.  See
# MIT-LICENSE for details.

require 'rake/rdoctask'
require 'rake/packagetask'

PKG_NAME = "laszlo-plugin"
PKG_VERSION = '0.7.1'
RUBYFORGE_PROJECT = 'laszlo-plugin'
RUBYFORGE_USER = ENV['RUBYFORGE_USER']

Rake::PackageTask.new(PKG_NAME, PKG_VERSION) do |p|
  p.need_tar = true
  p.need_zip = true
  p.package_files.include("./**/*")
  p.package_files.exclude 'pkg', 'rdoc'
  p.package_files.exclude 'notes.txt', '#*'
end

desc 'Generate documentation for the plugin.'
Rake::RDocTask.new(:rdoc) do |rd|
  rd.rdoc_dir = 'rdoc'
  rd.options << '--title' << "OpenLaszlo Rails Plugin" <<
    '--main' << 'README'
  rd.rdoc_files.include FileList['lib/*']
  rd.rdoc_files.include ['README', 'CHANGES', 'TODO', 'MIT-LICENSE']
end

task :publish_rdoc => :rdoc do
  sh" scp -r rdoc/* #{RUBYFORGE_USER}@rubyforge.org:/var/www/gforge-projects/#{RUBYFORGE_PROJECT}"
end

task :tag_svn do
  url = `svn info`[/^URL:\s*(.*\/)trunk/, 1]
  system("svn cp #{url}/trunk #{url}/tags/release_#{PKG_VERSION.gsub(/\./,'_')} -m 'tag release #{PKG_VERSION}'")
  system("svn cp #{url}/trunk #{url}/rails/plugins/openlaszlo -m 'tag release #{PKG_VERSION}'")
end
