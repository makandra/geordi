desc 'create-databases', 'Create all databases', :hide => true
def create_databases
  invoke_cmd 'create_database_yml'
  invoke_cmd 'bundle_install'

  announce 'Creating databases'

  if File.exists?('config/database.yml')
    command = 'bundle exec rake db:create:all'
    command << ' parallel:create' if file_containing?('Gemfile', /parallel_tests/)

    Util.system! command
  else
    puts 'config/database.yml does not exist. Nothing to do.'
  end
end
