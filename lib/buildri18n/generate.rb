
#This file generates the templates for showing the properties files.
# It also generates the html files if something definitive is agreed on.

#TODO stubs to generate from a bundle and down to a key/value.
#TODO the js to enter the value
#TODO the server side to communicate with the js in sinatra.
module Buildr::I18N
  
  module TemplateGeneration
    
    def page(bundle)
      <<-TXT
       #{head(bundle)}
       
       #{table(bundle)}
       
       #{footer(bundle)}
      TXT
    end
    
    def head(bundle)
      <<-TXT
      h1. #{bundle.path}
      TXT
    end
    
    def footer(bundle)
      ""
    end
    
    def table(bundle)
      props = bundle.sorted_properties
      table = "table{border:1px solid black}.\n|Keys|#{props.map(&:locale).join('|')}|"
      bundle.master.content.keys.sort.each do |key|
        table += "\n|key|#{props.collect {|prop| prop.content[key] || ""}.join("|")}|"
      end
      table
    end
    
  end
  
  class TemplateGenerationTask < Rake::FileTask
    include TemplateGeneration
    
    def initialize(*args)
      super(*args)
      enhance do
        # Create the templates.
        @bundles.each do |bundle|
          write "#{bundle.filename}.textile", page(bundle)
        end    
      end
    end
    
    
    private 
    
    def associate_with(project)
      prop_files = Buildr::I18N.find_properties_files(project)
      enhance prop_files
      @bundles = Buildr::I18N.group_properties(prop_files)
    end
      
  end
  
  module TemplateGenerationExtension
    include Extension
    
    first_time do
      desc 'Generate internationalization templates'
      Project.local_task('i18n') { |name| "Generate internationalization templates for #{name}" }
    end

    before_define(:i18n) do |project|
      if (project.projects.empty?) 
        i18n = ::Buildr::I18N::TemplateGenerationTask.define_task(project.path_to("_i18n"))
        i18n.send :associate_with, project
        task('i18n').enhance [i18n]
      end
    end
    
  end
  
end

class Buildr::Project
  include Buildr::I18N::TemplateGenerationExtension
end