desc 'setup', 'Setup a project for the first time'
long_desc <<-LONGDESC
Example: `geordi setup`

Check out a repository, cd into its directory. Now let `setup` do the tiring
work: run `bundle install`, create `database.yml`, create databases, migrate
(all if applicable).

After setting up, loads a dump into the development db when called with the
`--dump` option:

    geordi setup -d staging

After setting up, runs all tests when called with the `--test` option:

    geordi setup -t

See `geordi help setup` for details.
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
