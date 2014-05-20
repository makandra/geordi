require 'geordi/interaction'

module Geordi
  class Util
    class << self
      include Geordi::Interaction

      # Run a command with a clean environment.
      # Print an error message and exit if the command fails.
      def system!(*commands)
        options = commands.last.is_a?(Hash) ? commands.pop : {}

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
