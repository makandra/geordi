desc 'create_databases', 'Create all databases', :hide => true
def create_databases
  invoke 'create_database_yml'
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
