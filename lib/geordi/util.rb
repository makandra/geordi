require 'geordi/interaction'
require 'socket'
require 'bundler'

module Geordi
  class Util
    class << self

      # Geordi commands sometimes require external gems. However, we don't want
      # all employed gems as runtime dependencies because that would
      # unnecessarily slow down all commands.
      # Thus, we have this handy method here.
      def installing_missing_gems
        yield
      rescue LoadError => error
        error.message =~ /-- (\S+)\Z/
        Regexp.last_match(1) || raise # could not extract a gem name from the error message, re-raise the error

        gem_name = Regexp.last_match(1).strip.split('/').first
        install_command = 'gem install ' + gem_name

        # install missing gem
        Interaction.warn 'Probably missing gem: ' + gem_name
        Interaction.prompt('Install it now?', 'y', /y|yes/) || Interaction.fail('Missing Gems.')
        Util.run!(install_command, show_cmd: true)

        # retry
        Gem.clear_paths
        Interaction.note 'Retrying ...'
        require gem_name
        retry
      end

      # Run a command with a clean environment.
      # Print an error message and exit if the command fails.
      #
      # show_cmd: Whether to print the command
      # confirm: Whether to ask for confirmation before running it
      # fail_message: The text to print on command failure
      def run!(command, show_cmd: false, confirm: false, fail_message: 'Something went wrong.')
        # Disable shell features for arrays https://stackoverflow.com/questions/13338147/ruby-system-method-arguments
        # Conversion: ['ls *', 'some arg'] => ['ls', '*', 'some arg']
        # If you need shell features, you need to pass in a String instead of an array.
        if command.is_a?(Array)
          real_command, *arguments = *command
          command = [real_command.split(' '), arguments].flatten
          show_command = command
        else
          show_command = [command]
        end

        if show_cmd
          # Join with spaces for better readability and copy-pasting
          Interaction.note_cmd show_command.join(' ')
        end

        if confirm
          Interaction.prompt('Run this now?', 'n', /y|yes/) or Interaction.fail('Cancelled.')
        end

        if testing?
          # Join with commas for precise argument distinction
          puts "Util.run! #{show_command.join(', ')}"
        else
          # Remove Geordi's Bundler environment when running commands.
          success = if !defined?(Bundler)
            system(*command)
          elsif Gem::Version.new(Bundler::VERSION) >= Gem::Version.new('1.17.3')
            Bundler.with_original_env do
              system(*command)
            end
          else
            Bundler.clean_system(*command)
          end

          success || Interaction.fail(fail_message)
        end
      end

      def binstub_or_fallback(executable)
        binstub_file = "bin/#{executable}"

        File.exists?(binstub_file) ? binstub_file : "bundle exec #{executable}"
      end

      def console_command(environment)
        if gem_major_version('rails') == 2
          "script/console #{environment} -- --nomultiline"
        elsif gem_major_version('rails') == 3
          "#{binstub_or_fallback('rails')} console #{environment} -- --nomultiline"
        else
          "#{binstub_or_fallback('rails')} console -e #{environment} -- --nomultiline"
        end
      end

      def server_command
        if gem_major_version('rails') == 2
          'script/server ""'
        else
          "#{binstub_or_fallback('rails')} server"
        end
      end

      def current_branch
        if testing?
          'master'
        else
          `git rev-parse --abbrev-ref HEAD`.strip
        end
      end

      def staged_changes?
        if testing?
          ENV['GEORDI_TESTING_STAGED_CHANGES'] == 'true'
        else
          statuses = `git status --porcelain`.split("\n")
          statuses.any? { |l| /^[A-Z]/i =~ l }
        end
      end

      def deploy_targets
        Dir['config/deploy/*'].map do |f|
          File.basename f, '.rb' # Filename without .rb extension
        end
      end

      # try to guess user's favorite cli text editor
      def decide_texteditor
        %w[/usr/bin/editor vi].each do |texteditor|
          if cmd_exists?(texteditor) && texteditor.start_with?('$')
            return ENV[texteditor[1..-1]]
          elsif cmd_exists? texteditor
            return texteditor
          end
        end
      end

      # check if given cmd is executable. Absolute path or command in $PATH allowed.
      def cmd_exists?(cmd)
        system("which #{cmd} > /dev/null")
        $?.exitstatus.zero?
      end

      def is_port_open?(port)
        socket = TCPSocket.new('127.0.0.1', port)
        socket.close
        true
      rescue Errno::ECONNREFUSED
        false
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
        lock_file = Bundler::LockfileParser.new(Bundler.read_file(Bundler.default_lockfile))
        spec = lock_file.specs.detect { |spec| spec.name == gem }

        spec && spec.version
      end

      def file_containing?(file, regex)
        File.exist?(file) && File.read(file).scan(regex).any?
      end

      def testing?
        !!ENV['GEORDI_TESTING']
      end

    end
  end
end
