require 'geordi/capistrano_config'
require 'geordi/interaction'
require 'geordi/util'
require 'abbrev' # Dependency of Highline
require 'highline/import'
require 'pathname'
require 'fileutils'

module Geordi
  class Remote

    REMOTE_DUMP_PATH = '~/dumps/dump_for_download.dump'.freeze

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
      database = options[:database] ? " #{options[:database]}" : ''
      # Generate dump on the server
      shell options.merge({
        remote_command: "dumple #{@config.env}#{database} --for_download",
      })

      destination_directory = File.join(@config.root, 'tmp')
      FileUtils.mkdir_p destination_directory
      destination_path = File.join(destination_directory, "#{@stage}.dump")
      relative_destination = Pathname.new(destination_path).relative_path_from Pathname.new(@config.root)

      Interaction.note "Downloading remote dump to #{relative_destination} ..."
      server = @config.primary_server
      Util.run!("scp -C #{@config.user(server)}@#{server}:#{REMOTE_DUMP_PATH} #{destination_path}")

      Interaction.success "Dumped the#{database} #{@stage} database to #{relative_destination}."

      destination_path
    end

    def console(options = {})
      shell(options.merge(remote_command: Util.console_command(@config.env)))
    end

    def shell(options = {})
      server_option = options[:select_server]
      server_number = server_option.to_i

      server = if server_option == 'select_server'
        select_server
      elsif server_number != 0 && server_number <= @config.servers.count
        server_index = server_number - 1
        @config.servers[server_index]
      elsif server_option.nil?
        @config.primary_server
      else
        Interaction.warn "Invalid server number: #{server_option}"
        select_server
      end

      remote_command = "cd #{@config.remote_root} && #{@config.shell}"
      remote_command << " -c '#{options[:remote_command]}'" if options[:remote_command]

      Interaction.note 'Connecting to ' + server.to_s
      Util.run!(['ssh', "#{@config.user(server)}@#{server}", '-t', remote_command])
    end

  end
end
