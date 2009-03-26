module OpenLaszlo
  module Rails
    def self.install_javascripts
      sources = Dir[File.join(File.dirname(__FILE__), '..', 'javascripts', '*.js')]
      count = self.install_files(sources, "javascripts")
      puts "OpenLaszlo Plugin: installed #{count} JavaScript files" if count > 0
    end

    def self.install_express_install
      source = File.join(File.dirname(__FILE__), '..', 'assets', 'expressInstall.swf')
      count = self.install_files([source], ".")
      puts "OpenLaszlo Plugin: installed #{File.basename(source)}" if count > 0
    end

    private
    def self.install_files(files, dest_dir)
      # Array#count is not present in Ruby 1.8.
      count = 0
      files.map do |src_file|
        js_file = File.basename(src_file)
        dest_file = File.join(RAILS_ROOT, "public", dest_dir, js_file)
        next if File.exists?(dest_file) and
          File.mtime(dest_file) >= File.mtime(src_file) and
          File.size(dest_file) == File.size(src_file)
        FileUtils.cp_r(src_file, dest_file)
        count += 1
      end
      return count
    end
  end
end
