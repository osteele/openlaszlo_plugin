require 'fileutils'
gem 'ropenlaszlo', '>=0.5'
require 'openlaszlo'

module OpenLaszlo
  module Rails
    class Applet
      # An applet is any LZX file in app/applets/*/*.lzx whose name matches
      # one of the names below, where {dirname} is the name of the directory
      # that contains the file.
      def self.main_file_names; %w{main canvas applet application {dirname}}; end

      def self.from_source(source)
        self.new(source)
      end
      
      def self.from_target(target)
        self.new(source_dir_for_target(target), target)
      end
      
      attr_reader :source_dir, :target
      
      def initialize(source, target=nil)
        source = File.dirname(source) if File.ftype(source) == 'file'
        target ||= File.join(RAILS_ROOT, 'public/applets',
                             File.basename(source, '.lzx')+'.swf')
        @source_dir = source
        @target = target
      end

      def source
        self.class.main_file_names.map { |name|
          name = name.sub(/^\{dirname\}$/, File.basename(source_dir))
          pathname = File.join(source_dir, name) + '.lzx'
          pathname if File.exists?(pathname)
        }.compact.first or raise "No main file in #{source_dir}"
      end
      
      def uptodate?
        return false unless File.exists?(target)
        return File.mtime(target) >= Dir[File.join(source_dir, '**/*')].map { |f|
          File.mtime(f) rescue nil }.compact.max
      end
      
      def compile
        FileUtils::mkdir_p File.dirname(target)
        OpenLaszlo::compile(source, :output => target)
      end
      
      def update
        compile unless uptodate?
      end
      
      def self.source_dir_for_target(target)
        relative = File.expand_path(target).sub(File.expand_path(RAILS_ROOT), '')
        name = relative.sub(/^\/public\/applets\//, '').sub(/(\.swf)?(\?\d+)?$/, '')
        return File.join(RAILS_ROOT, 'app/applets', name)
      end
    end

    def self.applets(&block)
      applet_mains.map do |source|
        Applet.from_source(source)
      end
    end
    
    def self.update_asset(path)
      target = File.join(RAILS_ROOT, 'public', path.sub(/\?\d+$/, ''))
      Applet.from_target(target).update
    end
    
    private
    def self.applet_mains
      FileList[File.join(RAILS_ROOT, 'app/applets/*/*.lzx')].select { |path|
        Applet.main_file_names.map { |name|
          name.sub(/^\{dirname\}$/, File.basename(File.dirname(path)))
        }.include?(File.basename(path, '.lzx'))
      }
    end
  end
end
