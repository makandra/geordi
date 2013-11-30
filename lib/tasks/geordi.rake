require 'rake'
require 'bundler'

namespace :geordi do
  
  desc 'Setup a project for the first time'
  task :setup => [:create_databases, :update] do
    success 'Successfully set up the project.'
  end
  
  desc 'Update a project'
  task :update do
    
  end
  
  desc 'Create databases'
  task :create_databases => ['config/database.yml', :bundle] do  
    if File.exists?('config/database.yml')
      announce 'Creating databases'
      Bundler.clean_system 'bundle exec rake db:create:all'
    end
  end

  desc 'Create database.yml'
  file 'config/database.yml' do |file_task|
    sample_yml = 'config/database.sample.yml'

    if File.exists?(sample_yml)
      announce 'Creating ' + file_task.name
      print 'Please enter your DB password now: '
      db_password = STDIN.gets.strip

      sample = File.read(sample_yml)
      real = sample.gsub(/password:.*$/, "password: #{db_password}")
      File.open(file_task.name, 'w') { |f| f.write(real) }
      
      success "Successfully created #{file_task.name}."
    end
  end
  
  desc 'Bundle install'
  task :bundle do
    if File.exists?('Gemfile') and !quiet('bundle check')
      announce 'Bundle install'
      system 'bundle install'
    end
  end
  
  private
  
  def quiet(command)
    system("#{command} &>/dev/null")
  end
  
  def rvm_installed?
    quiet('rvm -v')
  end
  
  def announce(text)
    message = "\n# #{text}"
    puts "\e[4;34m#{message}\e[0m"
  end
  
  def success(text)
    message = "\n#{text}"
    puts "\e[32m#{message}\e[0m"
  end

end
