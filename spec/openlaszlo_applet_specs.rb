require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + "/../lib/openlaszlo_build_support")

include OpenLaszlo::Rails

describe Applet do
  describe :source_dir_for_target do
    it 'should return the applet directory' do
      Applet.source_dir_for_target("#{RAILS_ROOT}/public/applets/ap.swf").should == "#{RAILS_ROOT}/app/applets/ap"
    end
    
    it "should strip -debug option" do
      Applet.source_dir_for_target("#{RAILS_ROOT}/public/applets/ap-debug.swf").should == "#{RAILS_ROOT}/app/applets/ap"
    end
  end
  
  describe :options_from_target do
    it "should default to {}" do
      Applet.options_from_target("#{RAILS_ROOT}/public/applets/ap.swf").should == {}
    end
    
    it "should recognize -debug" do
      Applet.options_from_target("#{RAILS_ROOT}/public/applets/ap-debug.swf")[:debug].should == true
    end
  end
end
