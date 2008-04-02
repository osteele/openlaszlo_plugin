require 'openlaszlo'

module OpenLaszlo
  module Rails
    # An applet is any LZX file in app/applets/*/*.lzx whose name matches
    # one of the names below, where {dirname} is the name of the directory
    # that contains the file.
    APPLET_NAMES = %w{main canvas applet application {dirname}}

    def self.applet_mains
      FileList[File.join(RAILS_ROOT, 'app/applets/*/*.lzx')].select { |path|
        APPLET_NAMES.map { |n| n.sub(/^\{dirname\}$/, File.basename(File.dirname(path))) }.
          include?(File.basename(path, '.lzx')) }
    end
    
    def self.each_applet(&block)
      applet_mains.each do |source|
        target = File.join(RAILS_ROOT, 'public/applets',
                           File.basename(source, '.lzx')+'.swf')
        yield source, target
      end
    end
  end
end
