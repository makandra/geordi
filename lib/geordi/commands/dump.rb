desc 'dump [TARGET]', 'Handle dumps (see `geordi help dump` for details)'
long_desc <<-DESC
When called without arguments, dumps the development database with `dumple`.

    geordi dump

When called with the `--load` option, sources the specified dump into the
development database.

    geordi dump -l tmp/staging.dump

When called with a capistrano deploy target (e.g. `staging`), remotely dumps
the specified target's database and downloads it to `tmp/`.

    geordi dump staging

When called with a capistrano deploy target and the `--load` option, sources the
dump into the development database after downloading it.

    geordi dump staging -l
DESC

option :load, aliases: ['-l'], type: :string, desc: 'Load a dump'
option :select_server, type: :string, aliases: '-s'

def dump(target = nil, *_args)
  require 'geordi/dump_loader'
  require 'geordi/remote'

  if target.nil?
    if options.load
      # validate load option
      Interaction.fail 'Missing a dump file.' if options.load == 'load'
      File.exist?(options.load) || raise('Could not find the given dump file: ' + options.load)

      loader = DumpLoader.new(options.load)

      Interaction.announce "Sourcing dump into the #{loader.config['database']} db"
      loader.load

      Interaction.success "Your #{loader.config['database']} database has now the data of #{options.load}."

    else
      Interaction.announce 'Dumping the development database'
      Util.system! 'dumple development'
      Interaction.success 'Successfully dumped the development database.'
    end

  else
    Interaction.announce 'Dumping the database of ' + target
    dump_path = Geordi::Remote.new(target).dump(options)

    if options.load
      loader = DumpLoader.new(dump_path)

      Interaction.announce "Sourcing dump into the #{loader.config['database']} db"
      loader.load

      Interaction.success "Your #{loader.config['database']} database has now the data of #{target}."
    end
  end
end
