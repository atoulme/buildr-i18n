

unless defined?(SpecHelpers)
  
require File.join(File.dirname(__FILE__), "..", "lib", "buildri18n")

module SpecHelpers

  require 'sandbox'
  
  Spec::Runner.configure do |config|
    # Make all Buildr methods accessible from test cases.
    config.include Buildr, Buildr::I18N

    # Sanbdox Buildr for each test.
    config.include Sandbox
  end
end

end