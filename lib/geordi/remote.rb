require 'capistrano'
require 'geordi/capistrano_config'

module Geordi
  module Remote

    def initialize(stage)
      @stage = stage
    end

    def config
      @config ||= {}
      @config[stage] ||= CapistranoConfig.new(stage)
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

    def shell(options = {})
      server = select_server # option to skip this

      remote_commands = [ 'cd', config.path ]
      remote_commands << '&&' << config.shell
      remote_commands << "-c '#{options[:command]}'" if options[:command]

      args = [ 'ssh', %(#{config.user}@#{server}), '-t', remote_commands.join(' ') ]
      if options.fetch(:exec, true)
        exec(*args)
      else
        system(*args)
      end
    end


  end
end
