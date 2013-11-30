require 'thor'
require 'rake'
load File.expand_path('../../tasks/geordi.rake', __FILE__)

module Geordi
  class CLI < Thor
    
    desc 'setup', 'Setup a project for the first time'
    def setup
      Rake::Task['geordi:setup'].invoke
    end
  
    desc 'update', 'Make a project up to date'
    def update
      Rake::Task['geordi:update'].invoke
    end
    
    desc 'tests', 'Run all tests'
    def tests
      Rake::Task['geordi:tests'].invoke
    end
  
    desc 'dev_server', 'Start a development server'
    option :port, :type => :numeric, :default => 3000
    def dev_server
    
    end

  end
end
