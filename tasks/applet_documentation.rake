namespace :doc do
  desc "Generate documentation for the application. Set custom template with TEMPLATE=/path/to/rdoc/template.rb"
  Rake::RDocTask.new("applets") { |rdoc|
    rdoc.rdoc_dir = 'doc/applets'
    rdoc.template = ENV['template'] if ENV['template']
    rdoc.title    = "Rails Applet Documentation"
    rdoc.options << '--line-numbers' << '--inline-source'
    rdoc.options << '--charset' << 'utf-8'
    rdoc.options << '--main' << 'app/applets/README' if true
    rdoc.rdoc_files.include('app/applets/**/README')
  }
end
