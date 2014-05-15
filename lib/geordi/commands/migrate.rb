desc 'migrate', 'Migrate all databases'
long_desc <<-LONGDESC
Runs `power-rake db:migrate` if parallel_tests does not exist in your
`Gemfile`. Otherwise it runs migrations in your development environment and
executes `b rake parallel:prepare` after that.
LONGDESC

def migrate
  invoke 'bundle_install'
  announce 'Migrating'

  if File.directory?('db/migrate')
    if file_containing?('Gemfile', /parallel_tests/)
      system! 'bundle exec rake db:migrate parallel:prepare'
    else
      system! 'power-rake db:migrate'
    end
  else
    puts 'No migrations found.'
  end
end
