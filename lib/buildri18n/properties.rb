
module Buildr
  module I18N

    # Find all the properties file inside a project, inside sources, resources, or at the root.
    def I18N.find_properties_files(project)
      Dir.glob((File.join(project.base_dir, "**", "*.properties"))).delete_if {|file| file.match project.path_to("target")
        }.map {|path| Pathname.new(path).relative_path_from(Pathname.new(project.base_dir)).to_s}
    end

    # Group properties file per message bundle.
    # Make sure the default locale is found.
    #
    def I18N.group_properties(*args)
      # We map the properties per their path, minus the suffix if there is one.
      args.flatten.inject({}) {|map, file|
        prop = Properties.new(file)
        map[prop.bundle] ||= Bundle.new(prop.bundle)
        map[prop.bundle].properties << prop
        map
        }.values.sort {|a, b| a.path <=> b.path}
      end

      # A representation of a properties file.
      # It contains the elements of a properties file.
      #
      class Properties

        attr_reader :locale, :bundle, :path, :country, :content

        def initialize(path)
          @path = path
          segments = File.basename(path).sub(".properties", "").split("_")
          if (segments.size > 1)
            if (segments[-1].match /[A-Z]{2}/)
              @country = segments[-1]
              segments.delete_at(-1)
            end
            if (segments[-1].match /[a-z]{2}/)
              @locale = segments[-1]
              segments.delete_at(-1)
            end
          end
          @bundle = File.join(File.dirname(path), segments.join("_"))
          @content = File.exist?(path) ? Hash.from_java_properties(File.read(path)) : {}
        end

      end

      # An ensemble of properties files.
      # They represent the same values, in different locales.
      # One of the properties file is elected as the master file, containing the values 
      # in the default locale.
      class Bundle

        attr_reader :path
        attr_accessor :properties

        def initialize(path)
          @path = path
          @properties = []
        end

        # Returns the default properties file.
        def master
          unless @master
            no_suffix, en, en_US = nil
            properties.each {|prop|
              if prop.locale.nil?
                no_suffix = prop
              elsif prop.locale == 'en'
                en = prop
              elsif prop.locale == 'en_US'
                en_US = prop
              end
            }
            @master = no_suffix || en || en_US
          end
          @master
        end
        
        # Sorts the properties, placing the master as the first element, sorting the others on their locale.
        def sorted_properties
          properties.sort {|a,b| 
            case
            when a == master
              -1
            when b == master
              1
            else
              a.locale <=> b.locale
            end
          }
          
        end
        
        # A file name derived from the path of the bundle.
        def filename
          path.split(File::Separator).join("_")
        end

      end

    end

  end