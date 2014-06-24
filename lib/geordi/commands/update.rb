desc 'update', 'Bring a project up to date'
long_desc <<-LONGDESC
Brings a project up to date: git pull, bundle install (if necessary) and migrate (if applicable). See options for more.
LONGDESC

option :dump, :type => :string, :aliases => '-d', :banner => 'TARGET',
  :desc => 'After setup, dump the TARGET db and source it into the development db'
option :test, :type => :boolean, :aliases => '-t', :desc => 'After updating, run tests'

def update
  announce 'Updating repository'
  note_cmd 'git pull'
  Util.system! 'git pull'

  invoke_cmd 'migrate'

  success 'Successfully updated the project.'

  invoke_cmd 'dump', options.dump, :load => true if options.dump
  invoke_cmd 'tests' if options.test
end
