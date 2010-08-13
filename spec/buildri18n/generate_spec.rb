
require File.join(File.dirname(__FILE__), "..", "spec_helpers.rb")

describe Buildr::I18N::TemplateGeneration do
  
  before(:all) do
    write "src/messages_en_US.properties", "key=value"
    write "src/messages_fr.properties", "key=valeur"
    write "src/messages_de.properties", "key=wahl"
    write "src/messages_it.properties", ""
    @bundle = Buildr::I18N.group_properties("src/messages_en_US.properties", "src/messages_fr.properties", 
      "src/messages_de.properties", "src/messages_it.properties").first
    @tGen = Buildr::I18N::TemplateGenerationTask.define_task(".")
    
  end
  
  it 'should generate some textile for a property key' do
    table = @tGen.table(@bundle)
    table.should match /\|value\|wahl\|valeur\|\|/
  end
  
  
end