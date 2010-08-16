
require "jekylltask"

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
---
layout: default
title: #{bundle.path}
bundle: #{bundle.path}
---

h1. #{bundle.path}
TXT
    end
    
    def footer(bundle)
      ""
    end
    
    def text_field(key, locale, country, value)
      "<input type='text' id='#{key}_#{locale}' value='#{value}' onChange='update_value(#{key}, #{locale}, #{country}, this.value)' onLoad='this.value = get_value(#{key}, #{locale}, #{country})'/>"
    end
    
    def table(bundle)
      props = bundle.sorted_properties
      table = "table{border:1px solid black}.\n|Keys|#{props.map(&:locale).join('|')}|"
      bundle.master.content.keys.sort.each do |key|
        table += "\n|key|#{props.collect {|prop| text_field(key, prop.locale, prop.country, prop.content[key] || "")}.join("|")}|"
      end
      table
    end
    
  end
  
  class TemplateGenerationTask < Rake::Task
    include TemplateGeneration
    
    def initialize(*args)
      super(*args)
      enhance do
        mkdir_p File.join(@project.path_to("_i18n"), "_layouts")
        cp File.join(File.dirname(__FILE__), "templates", "default.html"), File.join(@project.path_to("_i18n"), "_layouts")
        # Create the templates.
        @bundles.each do |bundle|
          Buildr::write File.join(@project.path_to("_i18n"), "#{bundle.filename}.textile"), page(bundle)
        end    
        JekyllTask.new :jekyll do |task|
          task.source = @project.path_to("_i18n")
          task.target = @project.path_to("_i18n")
        end
        
        task(:jekyll).invoke
      end
    end
    
    
    private 
    
    def associate_with(project)
      @project = project
      prop_files = Buildr::I18N.find_properties_files(project)
      enhance prop_files
      @bundles = Buildr::I18N.group_properties(prop_files)
    end
      
  end
  
  class I18NBackendServerTask < Rake::Task
    require 'sinatra/base'

    class I18NBackend < Sinatra::Base

      post '/update_value' do

        new_value = request.body.read.to_s
      end

      get '/get_value' do
        @bundles.detect {|b| b.path == params[:bundle]}.properties.detect {|prop| 
          prop.locale == params[:locale] && prop.country == params[:country]
        }.content[params[:key]]
      end

    end

    private 
    
    def associate_with(project)
      @project = project
      prop_files = Buildr::I18N.find_properties_files(project)
      enhance prop_files
      @bundles = Buildr::I18N.group_properties(prop_files)
    end
    
  end
  
  module TemplateGenerationExtension
    include Extension
    
    first_time do
      desc 'Generate internationalization templates'
      Project.local_task('i18n:generate') { |name| "Generate internationalization templates for #{name}" }
      desc 'Run the backend server to update properties'
      Project.local_task('i18n:server') { |name| "Run the server for i18n" }
    end

    before_define do |project|
      if (project.projects.empty?) 
        i18n = ::Buildr::I18N::TemplateGenerationTask.define_task("i18n:generate")
        i18n.send :associate_with, project
        server = ::Buildr::I18N::I18NBackendServerTask.define_task("i18n:server")
        server.send :associate_with, project
      end
    end
    
  end
  
end

class Buildr::Project
  include ::Buildr::I18N::TemplateGenerationExtension
end