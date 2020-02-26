require 'geordi/capistrano_config'
require 'geordi/interaction'
require 'geordi/util'
require 'highline/import'
require 'pathname'

module Geordi
  class Remote
    include Geordi::Interaction

    REMOTE_DUMP_PATH = '~/dumps/dump_for_download.dump'
    REMOTE_DUMP_PATH_GZ = "#{REMOTE_DUMP_PATH}.gz"

    def initialize(stage)
      @stage = stage
      @config = CapistranoConfig.new(stage)
    end

    def select_server
      selected_server = choose do |menu|
        @config.servers.each do |server|
          menu.choice(server) { server }
        end

        # Default to the first listed server (by convention, the first server
        # in the deploy files is the primary one).
        menu.default = '1'
        menu.prompt = 'Connect to? [1] '
      end

      puts
      selected_server
    end

    def dump(options = {})
      # Generate dump on the server
      shell options.merge({
        :remote_command => "dumple #{@config.env} --for_download && gzip -f #{REMOTE_DUMP_PATH}",
        :select_server => nil # Dump must be generated on the primary server
      })

      destination_directory = File.join(@config.root, 'tmp')
      FileUtils.mkdir_p destination_directory
      destination_path = File.join(destination_directory, "#{@stage}.dump")
      destination_path_gz = "#{destination_path}.gz"

      relative_destination = Pathname.new(destination_path).relative_path_from Pathname.new(@config.root)
      relative_destination_gz = "#{relative_destination}.gz"

      note "Downloading remote dump to #{relative_destination_gz} ..."
      server = @config.primary_server
      Util.system! "scp -C #{ @config.user(server) }@#{ server }:#{REMOTE_DUMP_PATH_GZ} #{destination_path_gz} && gunzip -f #{destination_path_gz}"

      success "Dumped the #{@stage} database to #{relative_destination}."

      destination_path
    end

    def console(options = {})
      shell(options.merge :remote_command => Util.console_command(@config.env))
    end

    def shell(options = {})
      server = options[:select_server] ? select_server : @config.primary_server

      remote_command = "cd #{@config.remote_root} && #{@config.shell}"
      remote_command << " -c '#{options[:remote_command]}'" if options[:remote_command]

      note 'Connecting to ' + server.to_s
      Util.system! 'ssh', "#{ @config.user(server) }@#{ server }", '-t', remote_command
    end

  end
end
