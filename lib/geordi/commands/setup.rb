desc 'setup', 'Setup a project for the first time'
long_desc <<-LONGDESC
YOU check out a repository, cd into its directory and then let `setup` do the
tiring work: bundle install, create database.yml, create databases,
migrate (all if applicable). See options for more.
LONGDESC

option :dump, :type => :string, :aliases => '-d', :banner => 'TARGET',
  :desc => 'After setup, dump the TARGET db and source it into the development db'
option :test, :type => :boolean, :aliases => '-t', :desc => 'After setup, run tests'

def setup
  invoke_cmd 'create_databases'
  invoke_cmd 'migrate'

  success 'Successfully set up the project.'

  invoke_cmd 'dump', options.dump, :load => true if options.dump
  invoke_cmd 'tests' if options.test
end
