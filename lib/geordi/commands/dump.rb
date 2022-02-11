desc 'dump [TARGET]', 'Handle (remote) database dumps'
long_desc <<-DESC
`geordi dump` (without arguments) dumps the development database with `dumple`.

`geordi dump -l tmp/staging.dump` (with the `--load` option) sources the
specified dump file into the development database.

`geordi dump staging` (with a Capistrano deploy target) remotely dumps the
specified target's database and downloads it to `tmp/`.

`geordi dump staging -l` (with a Capistrano deploy target and the `--load`
option) sources the dump into the development database after downloading it.

If you are using multiple databases per environment, Geordi defaults to the
"primary" database, or the first entry in database.yml. To dump a specific
database, pass the database name like this:

    geordi dump -d primary

Loading a dump into one of multiple local databases is not supported yet.
DESC

option :load, aliases: '-l', type: :string, desc: 'Load a dump', banner: '[DUMP_FILE]'
option :database, aliases: '-d', type: :string, desc: 'Database name, if there are multiple databases', banner: 'NAME'

def dump(target = nil, *_args)
  require 'geordi/dump_loader'
  require 'geordi/remote'
  database = options[:database] ? "#{options[:database]} " : ''

  if target.nil? # Local …
    if options.load # … dump loading
      Interaction.fail 'Missing a dump file.' if options.load == 'load'
      File.exist?(options.load) || raise('Could not find the given dump file: ' + options.load)

      loader = DumpLoader.new(options.load)

      Interaction.announce "Sourcing dump into the #{loader.config['database']} db"
      loader.load

      Interaction.success "Your #{loader.config['database']} database has now the data of #{options.load}."

    else # … dump creation
      Interaction.announce 'Dumping the development database'
      Util.run!("dumple development #{database}")
      Interaction.success "Successfully dumped the #{database}development database."
    end

  else # Remote dumping …
    database_label = options[:database] ? " (#{database}database)" : ""

    Interaction.announce "Dumping the database of #{target}#{database_label}"
    dump_path = Geordi::Remote.new(target).dump(options)

    if options.load # … and dump loading
      loader = DumpLoader.new(dump_path)

      Interaction.announce "Sourcing dump into the #{loader.config['database']} db"
      loader.load

      Util.run! "rm #{dump_path}"
      Interaction.note "Dump file removed"

      Interaction.success "Your #{loader.config['database']} database has now the data of #{target}#{database_label}."
    end
  end
end
