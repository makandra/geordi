require 'thor'
require 'rake'
load File.expand_path('../../tasks/geordi.rake', __FILE__)

module Geordi
  class CLI < Thor
    
    desc 'setup [GIT_URL]', 'Setup a project for the first time'
    def setup(git_url = nil)
      Rake::Task['geordi:setup'].invoke
    end
  
    desc 'update', 'Make a project up to date'
    def update
      Rake::Task['geordi:update'].invoke
    end
  
    desc 'dev_server', 'Start a development server'
    option :port, :type => :numeric, :default => 3000
    def dev_server
    
    end

  end
end
