desc 'migrate', 'Migrate all databases'
long_desc <<-LONGDESC
Runs `power-rake db:migrate` if parallel_tests does not exist in your
`Gemfile`. Otherwise it runs migrations in your development environment and
executes `b rake parallel:prepare` after that.
LONGDESC

def migrate
  invoke_cmd 'bundle_install'
  announce 'Migrating'

  if File.directory?('db/migrate')
    if file_containing?('Gemfile', /parallel_tests/)
      Util.system! 'bundle exec rake db:migrate parallel:prepare'
    else
      invoke_cmd 'rake', 'db:migrate'
    end
  else
    puts 'No migrations directory found.'
  end
end
