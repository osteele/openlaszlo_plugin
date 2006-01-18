# Author:: Oliver Steele
# Copyright:: Copyright (c) 2006 Oliver Steele.  All rights reserved.
# License:: Ruby License.

task :update_javascripts do
  sources = Dir[File.expand_path(File.join(File.dirname(__FILE__), '../javascripts/*.js'))]
  cp sources, File.join(RAILS_ROOT, '/public/javascripts/')
end
