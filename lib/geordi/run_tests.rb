require File.join(File.dirname(__FILE__), 'cuc')

module Geordi
  class RunTests

    def run
      4.times { puts }
      puts "Running tests..."
      puts "========================="

      Cucumber.new.setup_vnc
      FirefoxForSelenium.setup_firefox
      exec *ARGV
    end

  end
end
