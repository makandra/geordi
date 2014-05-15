desc 'update', 'Bring a project up to date'
option :test, :type => :boolean, :aliases => '-t', :desc => 'After updating, run tests'
long_desc <<-LONGDESC
Brings a project up to date: Bundle (if necessary), perform a `git pull` and
migrate (if applicable), optionally run tests.
LONGDESC

def update
  git_pull
  invoke 'migrate'

  success 'Successfully updated the project.'

  invoke 'test' if options.test
end
