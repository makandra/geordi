desc 'setup', 'Setup a project for the first time'
long_desc <<-LONGDESC
Check out a repository, `cd <repo>`, then let `setup` do the tiring work for
you (all if applicable): bundle, create database.yml, create databases,
migrate. If run with `--test`, it will execute `geordi test all` afterwards.
LONGDESC

option :test, :type => :boolean, :aliases => '-t', :desc => 'After setup, run tests'

def setup
  invoke 'create_databases'
  invoke 'migrate'

  success 'Successfully set up the project.'

  invoke 'test' if options.test
end
