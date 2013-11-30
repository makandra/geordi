require 'rake'
require 'bundler'

namespace :geordi do
  
  desc 'Setup a project for the first time'
  task :setup => [:create_databases, :migrate] do
    success 'Successfully set up the project.'
  end
  
  desc 'Update a project'
  task :update => [:pull, :migrate] do
    success 'Successfully updated the project.'
  end
  
  desc 'Run all tests (rs, cuc, rake - only if present in project)'
  task :tests => [:bundle, :spec] do
    commands = []
    commands << 'cuc' if File.directory?('features')
    commands << 'rake' if file_containing?('Rakefile', /^task.+default.+(spec|test)/)
    
    if commands.any?
      command = commands.join ' && '
    
      announce "Running tests: #{command}"
      system!(command)
      success 'Successfully ran tests.'
    else
      puts "Nothing to do."
    end
  end
  
  desc 'Run RSpec'
  task :spec, :spec_args do |task, args|
    if File.directory?('spec')
      announce 'Running specs'
      spec_args = args[:spec_args] || []

      if file_containing?('Gemfile', /parallel_tests/) and spec_args.empty?
        note 'All specs at once (using parallel_tests)'
        system! 'b rake parallel:spec'

      else
        # tell which specs will be run
        if spec_args.empty?
          spec_args << 'spec/'
          note 'All specs in spec/'
        else
          note 'Only: ' + spec_args.join(', ')
        end
        
        command = ['b']
        # differentiate RSpec 1/2
        command << (File.exists?('script/spec') ? 'spec -c' : 'rspec')
        command << '-r rspec_spinner -f RspecSpinner::Bar' if file_containing?('Gemfile', /rspec_spinner/)
        command << spec_args.join(' ')
        
        puts
        system! command.join(' ')
      end

    else
      puts 'No RSpec here (directory spec/ does not exist).'
    end
  end
  
  desc 'Git pull'
  task :pull do
    announce 'Updating repository (git pull)'
    system! 'git pull'
  end
  
  desc 'Migrate'
  task :migrate => [:bundle] do
    if File.directory?('db/migrate')
      announce 'Migrating'
      
      if file_containing?('Gemfile', /parallel_tests/)
        system! 'b rake db:migrate parallel:prepare'
      else
        system! 'power-rake db:migrate'
      end
    end
  end
  
  desc 'Create databases (only if a database.yml exists)'
  task :create_databases => ['config/database.yml', :bundle] do  
    if File.exists?('config/database.yml')
      announce 'Creating databases'
      system! 'bundle exec rake db:create:all'
    end
  end

  desc 'Create database.yml (only if missing and .sample.yml exists)'
  file 'config/database.yml' do |file_task|
    sample_yml = 'config/database.sample.yml'

    if File.exists?(sample_yml)
      announce 'Creating ' + file_task.name
      print 'Please enter your DB password: '
      db_password = STDIN.gets.strip

      sample = File.read(sample_yml)
      real = sample.gsub(/password:.*$/, "password: #{db_password}")
      File.open(file_task.name, 'w') { |f| f.write(real) }
      
      success "Successfully created #{file_task.name}."
    end
  end
  
  desc 'Bundle install (only if needed)'
  task :bundle do
    if File.exists?('Gemfile') and !system('bundle check &>/dev/null')
      announce 'Bundling'
      system! 'bundle install'
    end
  end
  
  private
  
  def system!(*commands)
    # we cannot run Rake tasks natively (after all, we're inside a Rake
    # task), because we would probably not be using the version specified in
    # the Gemfile, and we don't want to add Geordi to a Gemfile either.
    Bundler.clean_system(*commands) or fail("Something went wrong.")
  end
    
  def announce(text)
    message = "\n# #{text}"
    puts "\e[4;34m#{message}\e[0m" # blue underline
  end
  
  def note(text)
    puts '> ' + text
  end
  
  def fail(text)
    message = "\n#{text}"
    puts "\e[31m#{message}\e[0m" # red
    exit(1)
  end
  
  def success(text)
    message = "\n#{text}"
    puts "\e[32m#{message}\e[0m" # green
  end
  
  def file_containing?(file, regex)
    File.exists?(file) and File.read(file).grep(regex).any?
  end

end
