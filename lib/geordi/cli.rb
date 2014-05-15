require 'thor'
require 'geordi/util'

module Geordi
  class CLI < Thor
    include Geordi::Util

    Dir[File.expand_path '../commands/*.rb', __FILE__].each do |file|
      class_eval File.read(file), file
    end

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
      invoke 'bundle_install'
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
      invoke 'bundle_install'

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
      invoke 'bundle_install'
      announce 'Creating databases'

      if File.exists?('config/database.yml')
        command = 'bundle exec rake db:create:all'
        command << ' parallel:create' if file_containing?('Gemfile', /parallel_tests/)

        system! command
      else
        puts 'config/database.yml does not exist. Nothing to do.'
      end
    end

    # This task lives here to prevent code duplication. Actually it should live
    # in CLI – move it there if you know how to invoke it from this class.
    desc 'bundle_install', 'Run bundle install if required', :hide => true
    def bundle_install
      if File.exists?('Gemfile') and !system('bundle check &>/dev/null')
        announce 'Bundling'
        system! 'bundle install'
      end
    end

    desc 'rspec', 'Run RSpec'
    long_desc <<-LONGDESC
    Runs RSpec as you want: RSpec 1&2 detection, bundle exec, rspec_spinner
    detection.
    LONGDESC
    def rspec(*files)
      if File.exists?('spec/spec_helper.rb')
        invoke Geordi::CLI, :bundle_install

        announce 'Running specs'

        if file_containing?('Gemfile', /parallel_tests/) and files.empty?
          note 'All specs at once (using parallel_tests)'
          system! 'bundle exec rake parallel:spec'

        else
          # tell which specs will be run
          if files.empty?
            files << 'spec/'
            note 'All specs in spec/'
          else
            note 'Only: ' + files.join(', ')
          end

          command = ['bundle exec']
          # differentiate RSpec 1/2
          command << (File.exists?('script/spec') ? 'spec -c' : 'rspec')
          command << '-r rspec_spinner -f RspecSpinner::Bar' if file_containing?('Gemfile', /rspec_spinner/)
          command << files.join(' ')

          puts
          system! command.join(' ')
        end
      else
        note 'RSpec not employed.'
      end
    end

    desc 'cucumber', 'Run Cucumber features'
    long_desc <<-LONGDESC
    Runs Cucumber as you want: bundle exec, cucumber_spinner detection,
    separate Firefox for Selenium, etc.
    LONGDESC
    def cucumber(*files)
      invoke Geordi::CLI, :bundle_install

      if File.directory?('features')
        announce 'Running features'
        Geordi::Cucumber.new.run(files) or fail
      else
        note 'Cucumber not employed.'
      end
    end

    desc 'unit', 'Run Test::Unit'
    def unit_tests
      if File.exists?('test/test_helper.rb')
        invoke Geordi::CLI, :bundle_install

        announce 'Running Test::Unit'
        system! 'bundle exec rake test'
      else
        note 'Test::Unit not employed.'
      end
    end

    desc 'with_rake', 'Run tests with `rake`'
    def with_rake
      if file_containing?('Rakefile', /^task.+default.+(spec|test)/)
        invoke Geordi::CLI, :bundle_install

        announce 'Running tests with `rake`'
        system! 'rake'
      else
        note '`rake` does not run tests.'
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

  end
end
