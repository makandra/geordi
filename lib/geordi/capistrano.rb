require 'capistrano'
require 'singleton'
require 'highline/import'

module Geordi
  module Capistrano

    class Config

      attr_accessor :stage, :root

      def initialize(stage)
        @stage = stage
        @root = find_project_root!
        load_capistrano_config
      end
      
      def user
        @capistrano_config.fetch(:user)
      end

      def servers
        @capistrano_config.find_servers(:roles => [:app])
      end
      
      def primary_server
        @capistrano_config.find_servers(:roles => [:app], :only => { :primary => true }).first
      end

      def path
        @capistrano_config.fetch(:deploy_to) + '/current'
      end

      def env
        @capistrano_config.fetch(:rails_env, 'production')
      end

      def shell
        @capistrano_config.fetch(:default_shell, 'bash --login')
      end
      

      private

      def load_capistrano_config
        config = ::Capistrano::Configuration.new
        config.load('deploy')
        config.load('config/deploy')
        if @stage and @stage != ''
          config.stage = @stage
          config.find_and_execute_task(stage)
        end

        @capistrano_config = config
      end

      def find_project_root!
        current = Dir.pwd
        until (File.exists? 'Capfile')
          Dir.chdir '..'
          raise 'Call me from inside a Rails project!' if current == Dir.pwd
          current = Dir.pwd
        end
        current
      end
    end


    attr_accessor :stage

    def config
      @config ||= {}
      @config[stage] ||= Config.new(stage)
    end

    def catching_errors(&block)
      begin
        yield
      rescue Exception => e
        $stderr.puts e.message
        exit 1
      end
    end
    
    def select_server
      choose do |menu|
        config.servers.each do |server|
          menu.choice(server) { server }
        end

        # Default to the first listed server (by convention, the first server
        # in the deploy files is the primary one).
        menu.default = '1'
        menu.prompt = 'Connect to? [1] '
      end
    end

    def shell_for(command, options = {})
      server = options[:select_server] ? select_server : config.primary_server
      
      remote_commands = [ 'cd', config.path ]
      remote_commands << '&&' << config.shell
      remote_commands << "-c '#{command}'" if command
      
      args = [ 'ssh', %(#{config.user}@#{server}), '-t', remote_commands.join(' ') ]
      if options.fetch(:exec, true)
        exec(*args)
      else
        system(*args)
      end
    end
  
  end
end
