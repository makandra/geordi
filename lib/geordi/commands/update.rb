desc 'update', 'Bring a project up to date'
option :test, :type => :boolean, :aliases => '-t', :desc => 'After updating, run tests'
long_desc <<-LONGDESC
Brings a project up to date: git pull, bundle install (if necessary) and migrate (if applicable). See options for more.
LONGDESC

def update
  announce 'Updating repository'
  note_cmd 'git pull'
  Util.system! 'git pull'

  invoke_cmd 'migrate'

  success 'Successfully updated the project.'

  invoke_cmd 'test' if options.test
end
