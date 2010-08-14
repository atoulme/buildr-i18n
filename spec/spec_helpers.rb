

unless defined?(SpecHelpers)
  
module SpecHelpers
  
  # For testing we use the gem requirements specified on the buildr4osgi.gemspec
  spec = Gem::Specification.load(File.expand_path('../buildr-i18n.gemspec', File.dirname(__FILE__)))
  spec.dependencies.each { |dep| gem dep.name, dep.requirement.to_s }
  # Make sure to load from these paths first, we don't want to load any
  # code from Gem library.
  $LOAD_PATH.unshift File.expand_path('../lib', File.dirname(__FILE__))
  require 'buildr-i18n'
    
  
  require 'sandbox'
  
  Spec::Runner.configure do |config|
    # Make all Buildr methods accessible from test cases.
    config.include Buildr

    # Sanbdox Buildr for each test.
    config.include Sandbox
  end
end

end