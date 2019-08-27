require 'geordi/interaction'
require 'socket'

module Geordi
  class Util
    class << self
      include Geordi::Interaction

      # Geordi commands sometimes require external gems. However, we don't want
      # all employed gems as runtime dependencies because that would
      # unnecessarily slow down all commands.
      # Thus, we have this handy method here.
      def installing_missing_gems(&block)
        yield
      rescue LoadError => error
        error.message =~ /-- (\S+)\Z/
        $1 or raise # could not extract a gem name from the error message, re-raise the error

        gem_name = $1.strip.split('/').first
        install_command = 'gem install ' + gem_name

        # install missing gem
        warn 'Probably missing gem: ' + gem_name
        prompt('Install it now?', 'y', /y|yes/) or fail 'Missing Gems.'
        system! install_command, :show_cmd => true

        # retry
        Gem.clear_paths
        note 'Retrying ...'
        require gem_name
        retry
      end

      # Run a command with a clean environment.
      # Print an error message and exit if the command fails.
      #
      # @option show_cmd: Whether to print the command
      # @option confirm: Whether to ask for confirmation before running it
      # @option fail_message: The text to print on command failure
      def system!(*commands)
        options = commands.last.is_a?(Hash) ? commands.pop : {}
        note_cmd commands.join(' ') if options[:show_cmd]

        if options[:confirm]
          prompt('Run this now?', 'n', /y|yes/) or fail('Cancelled.')
        end

        if ENV['GEORDI_TESTING']
          puts "Util.system! #{ commands.join ', ' }"
        else
          # Remove Geordi's Bundler environment when running commands.
          success = defined?(Bundler) ? Bundler.clean_system(*commands) : system(*commands)
          success or fail(options[:fail_message] || 'Something went wrong.')
        end
      end

      def console_command(environment)
        if gem_major_version('rails') == 2
          'script/console ' + environment
        elsif gem_major_version('rails') == 3
          'bundle exec rails console ' + environment
        else
          "bundle exec rails console -e #{environment}"
        end
      end

      def server_command
        if gem_major_version('rails') == 2
          'script/server ""'
        else
          'bundle exec rails server'
        end
      end

      def current_branch
        `git rev-parse --abbrev-ref HEAD`.strip
      end

      def deploy_targets
        Dir['config/deploy/*'].map do |f|
          File.basename f, '.rb' # Filename without .rb extension
        end
      end

      # try to guess user's favorite cli text editor
      def decide_texteditor
        %w[/usr/bin/editor vi].each do |texteditor|
          if cmd_exists? texteditor and texteditor.start_with? '$'
            return ENV[texteditor[1..-1]]
          elsif cmd_exists? texteditor
            return texteditor
          end
        end
      end

      # check if given cmd is executable. Absolute path or command in $PATH allowed.
      def cmd_exists? cmd
        system("which #{cmd} > /dev/null")
        return $?.exitstatus.zero?
      end

      def is_port_open?(port)
        begin
          socket = TCPSocket.new('127.0.0.1', port)
          socket.close
          return true
        rescue Errno::ECONNREFUSED
          return false
        end
      end

      # splint lines e.g. read from a file into lines and clean those up
      def stripped_lines(input_string)
        input_string.lines.map(&:chomp).map(&:strip)
      end

      def gem_available?(gem)
        !!gem_version(gem)
      end

      # Get the major version or for the given gem by parsing the Gemfile.lock.
      # Returns nil if the gem is not used.
      def gem_major_version(gem)
        gem_version = gem_version(gem)
        gem_version && gem_version.segments[0]
      end

      # Get the version for the given gem by parsing Gemfile.lock.
      # Returns nil if the gem is not used.
      def gem_version(gem)
        # Lines look like `* will_paginate (2.3.15)` or `railslts-version (2.3.18.16 7f51cc7)`
        bundle_list.split("\n").each do |line|
          matches = line.match(/\* #{gem} \(([\d\.]+)/)
          next if matches.nil? || matches[1].nil?

          return Gem::Version.new(matches[1])
        end

        nil
      end

      def file_containing?(file, regex)
        File.exists?(file) and File.read(file).scan(regex).any?
      end

      private

      def bundle_list
        @bundle_list ||= `bundle list`
      end

    end
  end
end
