desc 'update', 'Bring a project up to date'
long_desc <<-LONGDESC
Example: `geordi update`

Performs: `git pull`, `bundle install` (if necessary) and migrates (if applicable).

After updating, loads a dump into the development db when called with the
`--dump` option:

    geordi update -d staging

After updating, runs all tests when called with the `--test` option:

    geordi update -t

See `geordi help update` for details.
LONGDESC

option :dump, :type => :string, :aliases => '-d', :banner => 'TARGET',
  :desc => 'After updating, dump the TARGET db and source it into the development db'
option :test, :type => :boolean, :aliases => '-t', :desc => 'After updating, run tests'

def update
  announce 'Updating repository'
  Util.system! 'git pull', :show_cmd => true

  invoke_cmd 'migrate'

  success 'Successfully updated the project.'

  invoke_cmd 'dump', options.dump, :load => true if options.dump
  invoke_cmd 'tests' if options.test
end
