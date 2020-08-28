desc 'setup', 'Setup a project for the first time'
long_desc <<-LONGDESC
Example: `geordi setup`

Check out a repository and cd into its directory. Then let `setup` do the tiring
work: run `bundle install`, create `database.yml`, create databases, migrate
(all if applicable).

If a local bin/setup file is found, Geordi skips its routine and runs bin/setup
instead.
LONGDESC

option :dump, type: :string, aliases: '-d', banner: 'TARGET',
  desc: 'After setup, dump the TARGET db and source it into the development db'
option :test, type: :boolean, aliases: '-t', desc: 'After setup, run tests'

def setup
  if File.exist? 'bin/setup'
    Interaction.announce 'Running bin/setup'
    Interaction.note "Geordi's own setup routine is skipped"

    Util.run! 'bin/setup'
  else
    invoke_geordi 'create_databases'
    invoke_geordi 'migrate'
  end

  Interaction.success 'Successfully set up the project.'

  invoke_geordi 'dump', options.dump, load: true if options.dump
  invoke_geordi 'tests' if options.test
end
