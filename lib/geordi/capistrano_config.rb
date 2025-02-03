module Geordi
  class CapistranoConfig

    attr_accessor :root

    def initialize(stage)
      self.stage = stage
      self.root = find_project_root!
      load_deploy_info
    end

    def user(server)
      cap2user = deploy_info[/^\s*set\s*:user,\s*['"](.*?)['"]/, 1]
      cap2user || deploy_info[/^\s*server\s*['"]#{server}['"],.*user.{1,4}['"](.*?)['"]/, 1]
    end

    def servers
      deploy_info.scan(/^\s*server\s*\(?\s*['"](.*?)['"]/).flatten
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
      deploy_info[/^\s*set\s*:rails_env,\s*['"](.*?)['"]/, 1]
    end

    def shell
      'bash --login'
    end

    private

    attr_accessor :deploy_info, :stage

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
