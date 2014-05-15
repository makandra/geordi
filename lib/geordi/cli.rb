require 'thor'
require 'geordi/cli/test'
require 'geordi/cli/util'

module Geordi
  class CLI < Thor
    include Geordi::Util

    register Geordi::Test, :test, 'test', 'Subcommand, see: geordi test help'

    desc 'setup', 'Setup a project for the first time'
    option :test, :type => :boolean, :aliases => '-t', :desc => 'After setup, run tests'
    long_desc <<-LONGDESC
    Check out a repository, `cd <repo>`, then let `setup` do the tiring work for
    you (all if applicable): bundle, create database.yml, create databases,
    migrate. If run with `--test`, it will execute `geordi test all` afterwards.
    LONGDESC
    def setup
      invoke :create_databases
      invoke :migrate

      success 'Successfully set up the project.'

      invoke 'test:all' if options.test
    end

    desc 'update', 'Bring a project up to date'
    option :test, :type => :boolean, :aliases => '-t', :desc => 'After updating, run tests'
    long_desc <<-LONGDESC
    Brings a project up to date: Bundle (if necessary), perform a `git pull` and
    migrate (if applicable), optionally run tests.
    LONGDESC
    def update
      git_pull
      invoke :migrate

      success 'Successfully updated the project.'

      invoke 'test:all' if options.test
    end

    desc 'migrate', 'Migrate all databases'
    long_desc <<-LONGDESC
    Runs `power-rake db:migrate` if parallel_tests does not exist in your
    `Gemfile`. Otherwise it runs migrations in your development environment and
    executes `b rake parallel:prepare` after that.
    LONGDESC
    def migrate
      invoke 'test:bundle_install'
      announce 'Migrating'

      if migration_required?
        if file_containing?('Gemfile', /parallel_tests/)
          system! 'bundle exec rake db:migrate parallel:prepare'
        else
          system! 'power-rake db:migrate'
        end
      else
        puts 'No pending migrations.'
      end
    end

    desc 'devserver', 'Start a development server'
    option :port, :aliases => '-p', :default => '3000'
    def devserver
      invoke 'test:bundle_install'

      announce 'Booting a development server'
      note 'Port: ' + options.port

      command = if File.exists?('script/server')
        'script/server' # Rails 2
      else
        'bundle exec rails server' # Rails 3+
      end

      command << " -p #{options.port}"
      system command
    end

    desc 'version', 'Print the current version of geordi'
    def version
      require 'geordi/version'
      puts 'Geordi ' + Geordi::VERSION
    end

    desc 'create_databases', 'Create all databases', :hide => true
    def create_databases
      create_database_yml
      invoke 'test:bundle_install'
      announce 'Creating databases'

      if File.exists?('config/database.yml')
        command = 'bundle exec rake db:create:all'
        command << ' parallel:create' if file_containing?('Gemfile', /parallel_tests/)

        system! command
      else
        puts 'config/database.yml does not exist. Nothing to do.'
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

      # If there's no db/migrate directory, there are no migrations to run.
      # If there's no schema.rb, we haven't migrated yet -> we need to.
      # Else, check if the version from db/schema.rb matches the latest
      # migration.
      def migration_required?
        return false unless File.directory?('db/migrate')
        return true unless File.exists?('db/schema.rb')

        latest_version = Dir['db/migrate/*'].map do |file|
          file[/db\/migrate\/(\d+)/, 1].to_i
        end.max
        current_version = File.read('db/schema.rb')[/version.*(\d{14})/, 1].to_i

        current_version != latest_version
      end

    end

    private

    def invoke(name, task=nil, args = [], opts = {}, config=nil)

      super(name, task, args, opts, config)
    end

  end
end
