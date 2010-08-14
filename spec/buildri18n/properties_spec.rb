
require File.join(File.dirname(__FILE__), "..", "spec_helpers.rb")

describe "Buildr::I18N.find_properties_files" do
  
  before(:each) do
    write "src/main/java/SomeJava.java","public class SomeJava {}"
    write "src/main/resources/prop.properties","key=value"
    define "foo" do
      compile
    end
  end
  
  it 'should find the properties files placed in the resources' do
    Buildr::I18N.find_properties_files(project("foo")).should == [File.join(project("foo").base_dir, "src/main/resources/prop.properties")]
  end
  
  it 'should not pick up properties files placed in the target folder' do
    project("foo").compile.invoke
    Buildr::I18N.find_properties_files(project("foo")).should == [File.join(project("foo").base_dir, "src/main/resources/prop.properties")]
  end
  
end

describe "Buildr::I18N.group_properties" do
  
  it 'should create bundles by grouping properties' do
    result = Buildr::I18N.group_properties("src/main/resources/com/example/messages_fr.properties", 
      "src/main/resources/com/example/messages_de.properties",
      "src/main/resources/com/example/messages.properties")
    result.size.should == 1
    bundle = result.first
    bundle.path.should == "src/main/resources/com/example/messages"
    bundle.properties.size.should == 3
  end
  
end

describe Buildr::I18N::Properties do
  
  it 'should create a properties file by reading its path' do
    prop = Buildr::I18N::Properties.new("src/main/java/com/i/b/messages_fr.properties")
    prop.bundle.should == "src/main/java/com/i/b/messages"
    prop.locale.should == "fr"
    prop.path.should == "src/main/java/com/i/b/messages_fr.properties"
  end
  
  it 'should create a properties file by reading its path, even if underscores are part of the path' do
    prop = Buildr::I18N::Properties.new("src/main/java/com_err/i/b/messages_fr.properties")
    prop.bundle.should == "src/main/java/com_err/i/b/messages"
    prop.locale.should == "fr"
    prop.path.should == "src/main/java/com_err/i/b/messages_fr.properties"
  end
  
  it 'should read the country and locale' do
    prop = Buildr::I18N::Properties.new("src/main/java/com_err/i/b/messages_fr_CA.properties")
    prop.bundle.should == "src/main/java/com_err/i/b/messages"
    prop.locale.should == "fr"
    prop.country.should == "CA"
    prop.path.should == "src/main/java/com_err/i/b/messages_fr_CA.properties"
  end
  
  it 'should handle properties file with no locale suffixes' do
    prop = Buildr::I18N::Properties.new("src/main/java/com_err/i/b/messages.properties")
    prop.bundle.should == "src/main/java/com_err/i/b/messages"
    prop.locale.should be_nil
    prop.country.should be_nil
    prop.path.should == "src/main/java/com_err/i/b/messages.properties"
  end
  
  it 'should expose the properties file data' do
    write "src/main/java/com_err/i/b/messages.properties", "key=value"
    prop = Buildr::I18N::Properties.new("src/main/java/com_err/i/b/messages.properties")
    prop.content.should == {"key" => "value"}
  end
end

describe Buildr::I18N::Bundle do
  
  before(:each) do
    @bundle = Buildr::I18N::Bundle.new("src/main/resources/com/example/messages")
    @bundle.properties = [Buildr::I18N::Properties.new("src/main/resources/com/example/messages_fr.properties"),
      Buildr::I18N::Properties.new("src/main/resources/com/example/messages_de.properties")]
  end
  
  it 'should find the master as the properties file with no suffix' do
    @bundle.properties << Buildr::I18N::Properties.new("src/main/resources/com/example/messages.properties") 
    @bundle.master.should == @bundle.properties.last
  end
  
  it 'should find the master as the properties file with locale en if no file without suffix is provided' do
    @bundle.properties << Buildr::I18N::Properties.new("src/main/resources/com/example/messages_en.properties") 
    @bundle.master.should == @bundle.properties.last
  end
  
  it 'should find the master as the properties file with locale en and country US if no file without suffix or no file with locale en are provided' do
    @bundle.properties << Buildr::I18N::Properties.new("src/main/resources/com/example/messages_en_US.properties") 
    @bundle.master.should == @bundle.properties.last
  end
  
  it 'should sort properties, placing master first and the others in alphabetical order' do
    @bundle.properties << Buildr::I18N::Properties.new("src/main/resources/com/example/messages.properties")
    @bundle.sorted_properties.should == [@bundle.properties.last, @bundle.properties[1], @bundle.properties[0]]
    
  end
end