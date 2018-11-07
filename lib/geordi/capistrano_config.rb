module Geordi
  class CapistranoConfig

    attr_accessor :root

    def initialize(stage)
      self.stage = stage
      self.root = find_project_root!
      load_deploy_info
    end

    def user(server)
      cap2user = deploy_info[ /^set :user, ['"](.*?)['"]/, 1 ]
      cap2user || deploy_info[ /^server ['"]#{ server }['"],.*user.{1,4}['"](.*?)['"]/m, 1 ]
    end

    def servers
      deploy_info.scan(/^server ['"](.*?)['"]/).flatten
    end

    def primary_server
      # Actually, servers may have a :primary property. From Capistrano 3, the
      # first listed server is the primary one by default, which is a good-
      # enough default for us.
      servers.first
    end

    def remote_root
      File.join deploy_info[ /^set :deploy_to, ['"](.*?)['"]/, 1 ], 'current'
    end

    def env
      deploy_info[ /^set :rails_env, ['"](.*?)['"]/, 1 ]
    end

    def shell
      'bash --login'
    end

    private

    attr_accessor :deploy_info, :stage

    def load_deploy_info
      self.deploy_info = ''

      if stage
        deploy_info << File.read(File.join root, "config/deploy/#{ stage }.rb")
        deploy_info << "\n"
      end

      deploy_info << File.read(File.join root, 'config/deploy.rb')
    end

    def find_project_root!
      current = Dir.pwd
      until File.exists?('Capfile')
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
