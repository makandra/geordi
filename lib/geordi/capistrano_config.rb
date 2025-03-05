require 'geordi/capistrano_config_parser'

module Geordi
  class CapistranoConfig

    attr_accessor :root

    def initialize(stage)
      self.stage = stage
      self.root = find_project_root!
      load_deploy_info
    end

    def user(server)
      set_user = config_data[:user].first
      return set_user if set_user

      entry = config_data[:server][server]
      return nil unless entry

      entry[:user]
    end

    def servers
      config_data[:server].keys
    end

    def primary_server
      # Actually, servers may have a :primary property. From Capistrano 3, the
      # first listed server is the primary one by default, which is a good-
      # enough default for us.
      servers.first
    end

    def remote_root
      File.join deploy_info[/^\s*set\s*:deploy_to,\s*['"](.*?)['"]/, 1], 'current'
    end

    def env
      config_data[:rails_env].first
    end

    def shell
      'bash --login'
    end

    private

    attr_accessor :deploy_info, :stage

    def config_data
      @config_data ||= CapistranoConfigParser.parse(deploy_info)
    end

    def load_deploy_info
      lines = []
      self.deploy_info = ''

      if stage
        lines += File.readlines(File.join(root, "config/deploy/#{stage}.rb"))
      end

      lines += File.readlines(File.join(root, 'config/deploy.rb'))

      lines.each do |line|
        next if line =~ /^\s*#/ # Omit comment lines
        line.chomp! if line =~ /[\\,]\s*$/ # Join wrapped lines

        deploy_info << line
      end

      deploy_info
    end

    def find_project_root!
      current = ENV['RAILS_ROOT'] || Dir.pwd

      until File.exist?(File.join(current, 'Capfile'))
        if current == '/' || current == '/home' || !File.directory?(current)
          raise <<~ERROR
            Could not locate Capfile.

            Are you calling me from within a Rails project?
            Maybe Capistrano is not installed in this project.
          ERROR
        else
          current = File.dirname(current)
        end
      end

      current
    end

  end
end
