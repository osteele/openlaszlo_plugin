require 'rake/clean'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/contrib/rubyforgepublisher'

PKG_NAME = "laszlo-plugin"
PKG_VERSION = '0.9.2'
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
  rd.rdoc_dir = 'html'
  rd.options << '--title' << "OpenLaszlo Rails Plugin" <<
    '--main' << 'README.rdoc'
  rd.rdoc_files.include FileList['lib/*']
  rd.rdoc_files.include ['README.rdoc', 'CHANGES', 'TODO', 'MIT-LICENSE']
end

task :publish_rdoc => :rdoc do
  sh" scp -r html/* #{RUBYFORGE_USER}@rubyforge.org:/var/www/gforge-projects/#{RUBYFORGE_PROJECT}"
end

desc "Publish to RubyForge"
task :rubyforge => [:rdoc, :package] do
  require 'rubyforge'
  Rake::RubyForgePublisher.new(RUBYFORGE_PROJECT, 'osteele').upload
end

desc 'Package and upload the release to rubyforge.'
task :release => [:clean, :package] do |t|
  require 'rubyforge'
  pkg = "pkg/#{PKG_NAME}-#{PKG_VERSION}"
  
  rf = RubyForge.new
  rf.login
  
  c = rf.userconfig
  # c["release_notes"] = description if description
  # c["release_changes"] = changes if changes
  c["preformatted"] = true
  
  files = [ "#{pkg}.tgz" ].compact
  
  puts "Releasing #{PKG_NAME} v. #{PKG_VERSION}"
  rf.add_release RUBYFORGE_PROJECT, PKG_NAME, PKG_VERSION, *files
end

task :tag_svn do
  # svn co svn+ssh://osteele@rubyforge.org/var/svn/laszlo-plugin/trunk
  url = `svn info`[/^URL:\s*(.*\/)trunk/, 1]
  system("svn cp #{url}/trunk #{url}/tags/release_#{PKG_VERSION.gsub(/\./,'_')} -m 'tag release #{PKG_VERSION}'")
  system("svn cp #{url}/trunk #{url}/tags/openlaszlo -m 'tag release #{PKG_VERSION}'")
end
