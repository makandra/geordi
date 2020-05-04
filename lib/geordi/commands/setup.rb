desc 'setup', 'Setup a project for the first time'
long_desc <<-LONGDESC
Example: `geordi setup`

Check out a repository and cd into its directory. Then let `setup` do the tiring
work: run `bundle install`, create `database.yml`, create databases, migrate
(all if applicable).

If a local bin/setup file is found, Geordi skips these steps runs bin/setup
for setup instead.

After setting up, loads a remote database dump into the development db when
called with the `--dump` option:

    geordi setup -d staging

After setting up, runs all tests when called with the `--test` option:

    geordi setup -t
LONGDESC

option :dump, type: :string, aliases: '-d', banner: 'TARGET',
  desc: 'After setup, dump the TARGET db and source it into the development db'
option :test, type: :boolean, aliases: '-t', desc: 'After setup, run tests'

def setup
  if File.exist? 'bin/setup'
    announce 'Running bin/setup'
    note "Geordi's own setup routine is skipped"

    Util.system! 'bin/setup'
  else
    invoke_cmd 'create_databases'
    invoke_cmd 'migrate'
  end

  success 'Successfully set up the project.'

  invoke_cmd 'dump', options.dump, load: true if options.dump
  invoke_cmd 'tests' if options.test
end
