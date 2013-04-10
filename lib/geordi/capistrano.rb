require 'rubygems'
require 'bundler/setup'
require 'capistrano'
require 'singleton'

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

      def server
        @capistrano_config.find_servers(:roles => [:app]).first
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

    def shell_for(*args)
      options = {}
      if args.last.is_a?(Hash)
        options = args.pop
      end

      remote_command  = args.join(' ').strip
      
      login = %(#{config.user}@#{config.server})

      commands = [ "cd #{config.path}" ]
      if remote_command == ''
        commands << config.shell
      else
        commands << %{#{config.shell} -c '#{remote_command}'}
      end
      
      args = ['ssh', login, '-t', commands.join(' && ')]
      if options.fetch(:exec, true)
        exec(*args)
      else
        system(*args)
      end
    end
  
  end
end
