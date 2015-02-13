require 'capistrano'

module Geordi
  class CapistranoConfig

    attr_accessor :root

    def initialize(stage)
      ENV['BUNDLE_BIN_PATH'] = 'Trick capistrano safeguard in deploy.rb into believing bundler is present by setting this variable.'

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
        config[:stage] = @stage
        config.find_and_execute_task(@stage)
      end

      @capistrano_config = config
    end

    def find_project_root!
      current = Dir.pwd
      until (File.exists? 'Capfile')
        Dir.chdir '..'
        raise <<-ERROR if current == Dir.pwd
Could not locate Capfile.

Are you calling me from within a Rails project?
Maybe Capistrano is not installed in this project.
        ERROR

        current = Dir.pwd
      end
      current
    end

  end
end
