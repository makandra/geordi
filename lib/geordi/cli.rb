require 'thor'
require 'rake'
require 'geordi/cli_test'
load File.expand_path('../../tasks/geordi.rake', __FILE__)

module Geordi
  class CLI < Thor
    
    register(Geordi::CLITest, 'test', 'test', 'Run tests')

    desc 'setup', 'Setup a project for the first time'
    def setup
      Rake::Task['geordi:setup'].invoke
    end
  
    desc 'update', 'Bring a project up to date'
    def update
      Rake::Task['geordi:update'].invoke
    end
  
    desc 'dev_server', 'Start a development server'
    option :port, :type => :numeric, :default => 3000
    def dev_server
    
    end

  end
end
