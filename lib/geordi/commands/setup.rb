desc 'setup', 'Setup a project for the first time'
long_desc <<-LONGDESC
YOU check out a repository, cd into its directory and then let `setup` do the
tiring work: bundle install, create database.yml, create databases,
migrate (all if applicable). See options for more.
LONGDESC

option :test, :type => :boolean, :aliases => '-t', :desc => 'After setup, run tests'

def setup
  invoke_cmd 'create_databases'
  invoke_cmd 'migrate'

  success 'Successfully set up the project.'

  invoke_cmd 'test' if options.test
end
