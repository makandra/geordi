module Geordi
  class CapistranoConfig

    attr_accessor :root

    def initialize(stage)
      ENV['BUNDLE_BIN_PATH'] = 'Trick capistrano safeguard in deploy.rb into believing bundler is present by setting this variable.'

      @stage = stage
      @root = find_project_root!
      @config = {}
      load_capistrano_config
    end

    def user
      @config.fetch(:user, find_primary_server[:user])
    end

    def servers
      @config[:servers].select{|server| server[:roles].include?('app') }.map {|s| s[:host] }
    end

    def primary_server
      find_primary_server[:host]
    end

    def path
      @config.fetch(:deploy_to) + '/current'
    end

    def env
      @config.fetch(:rails_env, 'production')
    end

    def shell
      @config.fetch(:default_shell, 'bash --login')
    end

    def set(key, value)
      @config[key] = value
    end

    def server(key, value)
      @config[:servers] ||= []
      value[:host] = key
      value[:primary] = true if @config[:servers].empty?
      @config[:servers] << value
    end

    def lock(*args)
    end

    def namespace(*args)
    end

    def before(*args)
    end

    def after(*args)
    end

    private

    def find_primary_server
      @config[:servers].select{|s| s[:roles].include?("app") && s[:primary] }.first
    end

    def load_capistrano_config
      binding.eval(File.open(@root + '/config/deploy.rb').read, "deploy.rb")
      if @stage and @stage != ''
        @config[:stage] = @stage
        binding.eval(File.open(@root + "/config/deploy/#{@stage}.rb").read, "deploy/#{@stage}.rb")
      end
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
