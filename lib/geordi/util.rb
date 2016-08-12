require 'geordi/interaction'

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
          puts "Util.system! #{ commands.join(' ') }"
        else
          # Remove Geordi's Bundler environment when running commands.
          success = defined?(Bundler) ? Bundler.clean_system(*commands) : system(*commands)
          success or fail(options[:fail_message] || 'Something went wrong.')
        end
      end

      def console_command(environment)
        if File.exists?('script/console')
          'script/console ' + environment # Rails 2
        else
          'bundle exec rails console ' + environment
        end
      end

      def server_command
        if File.exists?('script/server')
          'script/server' # Rails 2
        else
          'bundle exec rails server' # Rails 3+
        end
      end

      def current_branch
        `git rev-parse --abbrev-ref HEAD`.strip
      end

      def retrieve_kernels
        current_kernel = `uname -r`.strip

        old_kernels = %x{
          dpkg --list |          # List installed packages
            grep linux-image |   # Filter
            awk '{ print $2 }' | # Print second field (= package name)
            sort -V |            # Sort ASC (version number mode)
            sed -n '/'#{ current_kernel }'/q;p' # Cut list at current kernel
        }.split("\n")

        { :current => current_kernel, :old => old_kernels }
      end

      def root_required
        unless ENV['GEORDI_TESTING']
          user = `whoami`.strip
          user == 'root' or fail 'Run this as root.'
        end
      end

    end
  end
end
