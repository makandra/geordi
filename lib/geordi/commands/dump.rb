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
"primary" database, or the first entry in database.yml. To target a specific
database, pass the database name like this:
```
geordi dump -d primary
```

You can specify a compress algorithm:
```
geordi dump -c=zstd:3
```

When used with the blank `load` option ("dump and source"), the `database` option
will be respected both for the remote *and* the local database. If these should
not match, please issue separate commands for dumping (`dump -d`) and sourcing
(`dump -l -d`).
DESC

option :load, aliases: '-l', type: :string, desc: 'Load a dump', banner: '[DUMP_FILE]'
option :database, aliases: '-d', type: :string, desc: 'Target database, if there are multiple databases', banner: 'NAME'
option :compress_algorithm, aliases: '-c', type: :string, desc: 'Specify a compress algorithm'

def dump(target = nil, *_args)
  require 'geordi/dump_loader'
  require 'geordi/remote'
  database = options[:database] ? "#{options[:database]} " : ''
  compress_algorithm = "--compress-algorithm=#{options['compress_algorithm']}" if options['compress_algorithm']

  if target.nil? # Local …
    if options.load # … dump loading
      Interaction.fail 'Missing a dump file.' if options.load == 'load'
      File.exist?(options.load) || raise('Could not find the given dump file: ' + options.load)

      loader = DumpLoader.new(options.load, options.database)

      Interaction.announce "Sourcing dump into the #{loader.config['database']} db"
      loader.load

      Interaction.success "Your #{loader.config['database']} database has now the data of #{options.load}."

    else # … dump creation
      Interaction.announce 'Dumping the development database'
      Util.run!(['dumple', compress_algorithm, 'development', options[:database]].compact.join(' '))
      Interaction.success "Successfully dumped the #{database}development database."
    end

  else # Remote dumping …
    database_label = options[:database] ? " (#{database}database)" : ""

    Interaction.announce "Dumping the database of #{target}#{database_label}"
    dump_path = Geordi::Remote.new(target).dump(options)

    if options.load # … and dump loading
      loader = DumpLoader.new(dump_path, options.database)

      Interaction.announce "Sourcing dump into the #{loader.config['database']} db"
      loader.load

      Util.run! "rm #{dump_path}"
      Interaction.note "Dump file removed"

      Interaction.success "Your #{loader.config['database']} database has now the data of #{target}#{database_label}."
    end
  end

  Hint.did_you_know [
    :delete_dumps,
    :drop_databases,
    :migrate,
    'Geordi can load a dump directly into the local database if passed a Capistrano stage and the option -l. See `geordi help dump`.',
  ]
end
