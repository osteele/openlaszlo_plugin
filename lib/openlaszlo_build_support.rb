require 'fileutils'
gem 'ropenlaszlo', '>=0.6.3'
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
        self.new(source_dir_for_target(target), target, options_from_target(target))
      end
      
      def self.source_dir_for_target(target)
        target = target.sub(/-debug(\.swf)/, '\1')
        relative = File.expand_path(target).sub(File.expand_path(RAILS_ROOT), '')
        name = relative.sub(/^\/public\/applets\//, '').sub(/(\.swf)?(\?\d+)?$/, '')
        return File.join(RAILS_ROOT, 'app/applets', name)
      end
      
      def self.options_from_target(target)
        options = {}
        options[:debug] = true if target =~ /-debug(\.swf)/
        options
      end
    end

    class Applet
      attr_reader :name, :source_dir, :target, :options
      
      def initialize(source, target=nil, options={})
        @name = File.basename(source)
        source = File.dirname(source) if File.ftype(source) == 'file'
        target ||= File.join(RAILS_ROOT, 'public/applets',
                             File.basename(source, '.lzx')+'.swf')
        @source_dir = source
        @target = target
        @options = options
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
        source_files = Dir[File.join(source_dir, '**/*')] +
          Dir[File.join(RAILS_ROOT, 'lib/**/*')]
        return File.mtime(target) >= source_files.map { |f|
          File.mtime(f) rescue nil }.compact.max
      end
      
      def compile
        FileUtils::mkdir_p File.dirname(target)
        compilation_options = options.clone
        compilation_options[:output] = target
        results = OpenLaszlo::compile(source, compilation_options)
        which_compiler = case results[:compiler]
                         when OpenLaszlo::CompileServer
                         when OpenLaszlo::CommandLineCompiler then
                           " with the command-line compiler"
                         end
        ActiveRecord::Base.logger.info "Compiled #{name} applet#{which_compiler}" rescue nil
        if results[:warnings] and results[:warnings].any?
          ActiveRecord::Base.logger.warn "Warnings:" rescue puts "Warnings:"
          results[:warnings].each do |warning|
            ActiveRecord::Base.logger.warn warning rescue puts warning
          end
        end
      end
      
      def update
        compile unless uptodate?
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
      (FileList[File.join(RAILS_ROOT, 'app/applets/*/*.lzx')] -
         FileList[File.join(RAILS_ROOT, 'app/applets/lib/*.lzx')] -
         FileList[File.join(RAILS_ROOT, 'app/applets/spec/*.lzx')] -
         FileList[File.join(RAILS_ROOT, 'app/applets/test/*.lzx')]).select { |path|
        Applet.main_file_names.map { |name|
          name.sub(/^\{dirname\}$/, File.basename(File.dirname(path)))
        }.include?(File.basename(path, '.lzx'))
      }
    end
  end
end
