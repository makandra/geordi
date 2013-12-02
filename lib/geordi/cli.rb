require 'thor'
require 'rake'
load File.expand_path('../tasks/geordi.rake', __FILE__)
require 'geordi/cli_test'

module Geordi
  class CLI < Thor
    
    register Geordi::CLITest, :test, 'test', 'Run tests'

    # fix help for subcommand 'test'
    Geordi::CLITest.class_eval <<-RUBY
      def help(command = nil, subcommand = false)
        subcommand ? self.class.command_help(shell, subcommand) : self.class.help(shell, false)
      end
    RUBY

    desc 'setup', 'Setup a project for the first time'
    option :test, :type => :boolean, :aliases => '-t', :desc => 'After updating, run tests'
    def setup
      Rake::Task['geordi:create_databases'].invoke
      Rake::Task['geordi:migrate'].invoke
      invoke :test if options.test
      
      success 'Successfully set up the project.'
    end
  
    desc 'update', 'Bring a project up to date'
    option :test, :type => :boolean, :aliases => '-t', :desc => 'After updating, run tests'
    def update
      Rake::Task['geordi:pull'].invoke
      Rake::Task['geordi:migrate'].invoke
      invoke :test if options.test
      
      success 'Successfully updated the project.'
    end
  
    desc 'migrate', 'Migrate all databases'
    def migrate
      Rake::Task['geordi:migrate']
    end
  
    desc 'server', 'Start a development server'
    option :port, :aliases => '-p', :default => '3000'
    def server
      Rake::Task['geordi:server'].invoke(options.port)
    end
    
    desc 'shell STAGE', 'Open a shell on the STAGE server'
    option :command, :type => :string, :aliases => '-c', :desc => 'Execute COMMAND on the STAGE server'
    def shelll(env) # 'shell' is a Thor reserved word
      fail 'Option --command currently not supported.' if options.command
      Rake::Task['geordi:shell'].invoke(env)
    end    
    
    desc 'console [STAGE]', 'Open a console, either locally or on the STAGE server'
    def console(env = nil)
      Rake::Task['geordi:console'].invoke(env)
    end
    
    desc 'dump [STAGE]', 'Dump the database, either locally or on the STAGE server'
    option :load, :type => :boolean, :aliases => '-l', :desc => 'After dumping, load the dump'
    def dump(env = nil)
      Rake::Task['geordi:dump'].invoke(env)
      Rake::Task['geordi:load_dump'].invoke if options.load
    end

  end
end
