$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'modbuild'

describe Modbuild::Base, '#get_package_files' do
  it "should extract variables from comments" do
    pkg = Modbuild::Base.new File.dirname(__FILE__) + '/fixtures/001_variables'
    pkg.get_package_files
    
    pkg.package_name.should eq 'My Magento Extension'
    pkg.package_version.should eq '1.0.1'
    pkg.package_summary.should eq 'My extension summary'
    pkg.package_description.should eq 'My extension description'
  end
end

describe Modbuild::PackageXml, '#identify_file' do
  it "should identify file targets" do
    pkgxml = Modbuild::PackageXml.new 'a', 'b', 'c', 'd'
    
    pkgxml.identify_file('app/code/local/Meanbee/Awesome')[:target].should eq 'magelocal'
    pkgxml.identify_file('app/code/community/Meanbee/Awesome')[:target].should eq 'magecommunity'
    pkgxml.identify_file('app/code/core/Meanbee/Awesome')[:target].should eq 'magecore'
    pkgxml.identify_file('app/etc/modules/Meanbee_Awesome.xml')[:target].should eq 'mageetc'
    pkgxml.identify_file('app/design/frontend/base/default/template/meanbee/awesome')[:target].should eq 'magedesign'
    pkgxml.identify_file('skin/frontend/base/default/css/awesome.css')[:target].should eq 'mageskin'
    pkgxml.identify_file('random/directory/file.css')[:target].should eq 'mageweb'
  end
  
  it "should differentiate between files and directories" do
    pkgxml = Modbuild::PackageXml.new 'a', 'b', 'c', 'd'
    
    pkgxml.identify_file('app/code/local/Meanbee/Awesome')[:type].should eq 'dir'
    pkgxml.identify_file('app/code/local/Meanbee/Awesome/')[:type].should eq 'dir'
    pkgxml.identify_file('app/code/local/Meanbee/Awesome/etc/config.xml')[:type].should eq 'file'
    pkgxml.identify_file('app/code/local/Meanbee/Awesome/etc/.htaccess')[:type].should eq 'file'
    pkgxml.identify_file('app/code/local/Meanbee/Awesome/etc/.htaccess/')[:type].should eq 'dir'
    pkgxml.identify_file('app/code/local/Meanbee/Awesome/etc/.htaccess/subdir')[:type].should eq 'dir'
    pkgxml.identify_file('app/code/local/Meanbee/Awesome/etc/.htaccess/subdir/file.txt')[:type].should eq 'file'
    pkgxml.identify_file('.htaccess')[:type].should eq 'file'
  end
  
  it "should provide file paths relative to target base directories" do
    pkgxml = Modbuild::PackageXml.new 'a', 'b', 'c', 'd'
    
    pkgxml.identify_file('app/code/local/Meanbee/Awesome')[:path].should eq 'Meanbee/Awesome'
    pkgxml.identify_file('app/code/community/Meanbee/Awesome')[:path].should eq 'Meanbee/Awesome'
    pkgxml.identify_file('app/code/core/Meanbee/Awesome')[:path].should eq 'Meanbee/Awesome'
    pkgxml.identify_file('app/etc/modules/Meanbee_Awesome.xml')[:path].should eq 'modules/Meanbee_Awesome.xml'
    pkgxml.identify_file('app/design/frontend/base/default/template/meanbee/awesome')[:path].should eq 'frontend/base/default/template/meanbee/awesome'
    pkgxml.identify_file('skin/frontend/base/default/css/awesome.css')[:path].should eq 'frontend/base/default/css/awesome.css'
    pkgxml.identify_file('random/directory/file.css')[:path].should eq 'random/directory/file.css'
  end
end