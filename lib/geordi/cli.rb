require 'thor'
require 'bundler'
require 'geordi/cli/test'

module Geordi
  class CLI < Thor

    register Geordi::Test, :test, 'test', 'Run tests'

    desc 'setup', 'Setup a project for the first time'
    option :test, :type => :boolean, :aliases => '-t', :desc => 'After updating, run tests'
    long_desc <<-LONGDESC
    Check out a repository, `cd <repo>`, then let `setup` do the tiring work for
    you (all if applicable): bundle, create database.yml, create databases,
    migrate. If run with `--test`, it will execute `geordi test all` afterwards.
    LONGDESC
    def setup
      invoke :create_databases
      invoke :migrate

      success 'Successfully set up the project.'

      run 'test:all' if options.test
    end

    desc 'update', 'Bring a project up to date'
    option :test, :type => :boolean, :aliases => '-t', :desc => 'After updating, run tests'
    long_desc <<-LONGDESC
    Brings a project up to date. Bundle (if necessary), perform a `git pull` and
    migrate (if applicable), optionally run tests.
    LONGDESC
    def update
      git_pull
      invoke :migrate

      success 'Successfully updated the project.'

      run 'test:all' if options.test
    end

    desc 'migrate', 'Migrate all databases'
    long_desc <<-LONGDESC
    Runs `power-rake db:migrate` if parallel_tests does not exist in your
    `Gemfile`. Otherwise it runs migrations in your development environment and
    executes `b rake parallel:prepare` after that.
    LONGDESC
    def migrate
      invoke :bundle_install

      if File.directory?('db/migrate')
        announce 'Migrating'

        if file_containing?('Gemfile', /parallel_tests/)
          system! 'bundle exec rake db:migrate parallel:prepare'
        else
          system! 'power-rake db:migrate'
        end
      end
    end

    desc 'devserver', 'Start a development server'
    option :port, :aliases => '-p', :default => '3000'
    def devserver
      invoke :bundle_install

      if File.directory?('public')
        announce 'Booting a development server'
        note 'Port: ' + options.port

        command = if File.exists?('script/server')
          'script/server' # Rails 2
        else
          'bundle exec rails server' # Rails 3+
        end

        command << " -p #{options.port}"
        system command
      else
        # We're probably not inside a Rails app, but a Gem.
      end
    end

    desc 'version', 'Print the current version of geordi'
    def version
      require 'geordi/version'
      puts 'Geordi ' + Geordi::VERSION
    end

    desc 'create_databases', 'Create all databases', :hide => true
    def create_databases
      create_database_yml
      invoke :bundle_install

      if File.exists?('config/database.yml')
        announce 'Creating databases'

        command = 'bundle exec rake db:create:all'
        command << ' parallel:create' if file_containing?('Gemfile', /parallel_tests/)

        system! command
      end
    end

    desc 'bundle', 'Run bundle install if required', :hide => true
    long_desc <<-LONGDESC
    Run bundle install if a) a Gemfile exists and b) `bundle check` has a
    non-zero exit status.
    LONGDESC
    def bundle_install
      if File.exists?('Gemfile') and !system('bundle check &>/dev/null')
        announce 'Bundling'
        system! 'bundle install'
      end
    end

    no_tasks do

      def git_pull
        announce 'Updating repository'
        note 'git pull'
        system! 'git pull'
      end

      def create_database_yml
        real_yml = 'config/database.yml'
        sample_yml = 'config/database.sample.yml'

        if File.exists?(sample_yml) and not File.exists?(real_yml)
          announce 'Creating ' + real_yml

          print 'Please enter your DB password: '
          db_password = STDIN.gets.strip

          sample = File.read(sample_yml)
          real = sample.gsub(/password:.*$/, "password: #{db_password}")
          File.open(real_yml, 'w') { |f| f.write(real) }

          note "Created #{real_yml}."
        end
      end

    end

    private

    def run(command)
      sub, command = command.split(':')
      invoke(sub, command, [], []) # weird API
    end

    def system!(*commands)
      # Remove the gem's Bundler environment when running command.
      Bundler.clean_system(*commands) or fail
    end

    def file_containing?(file, regex)
      File.exists?(file) and File.read(file).scan(regex).any?
    end

  end
end
