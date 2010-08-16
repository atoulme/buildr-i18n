
require File.join(File.dirname(__FILE__), "..", "spec_helpers.rb")

describe Buildr::I18N::TemplateGeneration do
  
  before(:each) do
    write "src/messages_en_US.properties", "key=value"
    write "src/messages_fr.properties", "key=valeur"
    write "src/messages_de.properties", "key=Wert"
    write "src/messages_it.properties", ""
    @bundle = Buildr::I18N.group_properties("src/messages_en_US.properties", "src/messages_fr.properties", 
      "src/messages_de.properties", "src/messages_it.properties").first
    @tGen = Buildr::I18N::TemplateGenerationTask.define_task(".")
    
  end
  
  it 'should generate some textile for a property key' do
    table = @tGen.table(@bundle)
    table.should match /\|Keys\|en\|de\|fr\|it\|\n\|key\|/
  end
  
end

describe Buildr::I18N::TemplateGenerationTask do
  
  before(:each) do
    write "src/messages_en_US.properties", "key=value"
    write "src/messages_fr.properties", "key=valeur"
    write "src/messages_de.properties", "key=Wert"
    write "src/messages_it.properties", ""
    @foo = define "foo" do
    end
    @foo.invoke
  end
  
  it 'should have a i18n task' do
    @foo.task('i18n:generate').should be_instance_of Buildr::I18N::TemplateGenerationTask 
  end
  
  it 'should generate the textile files under the _i18n folder' do
    lambda { @foo.task('i18n:generate').invoke  }.should change {File.exist?(@foo.path_to("_i18n/src_messages.textile"))}.from(false).to(true)
    File.exist?(@foo.path_to("_i18n/_layouts/default.html")).should be_true
    File.read(@foo.path_to("_i18n/src_messages.textile")).should match <<-TXT
h1. src/messages


table{border:1px solid black}.
|Keys|en|de|fr|it|
|key|value|Wert|valeur||


TXT
  end
  
  it 'should generate the html files under the _i18n folder' do
    lambda { @foo.task('i18n:generate').invoke }.should change {File.exist?(@foo.path_to("_i18n/src_messages.html"))}.from(false).to(true)
    
  end
  
end
    