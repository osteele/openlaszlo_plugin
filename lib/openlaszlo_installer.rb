module OpenLaszlo
  module Rails
    def self.install_javascripts
      dir = "javascripts"
      count = 0
      Dir["#{File.dirname(__FILE__)}/../#{dir}/*.js"].each do |src_file|
        #src_file = File.join(File.dirname(__FILE__), '..', dir, js_file)
        js_file = File.basename(src_file)
        dest_file = File.join(RAILS_ROOT, "public", dir, js_file)
        next if File.exists?(dest_file) and
          File.mtime(dest_file) >= File.mtime(src_file) and
          File.size(dest_file) == File.size(src_file)
        FileUtils.cp_r(src_file, dest_file)
        count += 1
      end
      puts "Files copied - Installation complete!" if count > 0
    end
  end
end
