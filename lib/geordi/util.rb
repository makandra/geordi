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
      rescue LoadError => e
        gem_name = e.message.split('--').last.strip
        install_command = 'gem install ' + gem_name

        # install missing gem
        warn 'Probably missing gem: ' + gem_name
        wait 'Auto-install it?'
        system! install_command, :show_cmd => true

        # retry
        Gem.clear_paths
        note 'Trying again ...'
        require gem_name
        retry
      end

      # Run a command with a clean environment.
      # Print an error message and exit if the command fails.
      #
      # Options: show_cmd, fail_message
      def system!(*commands)
        options = commands.last.is_a?(Hash) ? commands.pop : {}
        note_cmd commands.join(' ') if options[:show_cmd]

        # Remove the gem's Bundler environment when running commands.
        Bundler.clean_system(*commands) or fail(options[:fail_message] || 'Something went wrong.')
      end

      def console_command(environment)
        if File.exists?('script/console')
          'script/console ' + environment # Rails 2
        else
          'bundle exec rails console' + environment
        end
      end

      def server_command
        if File.exists?('script/server')
          'script/server' # Rails 2
        else
          'bundle exec rails server' # Rails 3+
        end
      end

    end
  end
end
