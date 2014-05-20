desc 'dump [TARGET]', 'Handle dumps'
long_desc <<-DESC
When called without arguments, dumps the development database with `dumple`.

When called with the --load option, sources the specified dump into the
development database.

When called with a capistrano deploy target (e.g. staging), remotely dumps
the specified target's database and downloads it.

When called with a capistrano deploy target and the --load option, sources the
dump into the development database after downloading it.
DESC

option :load, :aliases => ['-l'], :type => :string, :desc => 'Load a dump'

def dump(target = nil, *args)
  require 'geordi/dump_loader'
  require 'geordi/remote'

  if target.nil?
    if options.load
      # validate load option
      fail 'Missing a dump file.' if options.load == 'load'
      File.exists?(options.load) or fail 'Could not find the given dump file: ' + options.load

      loader = DumpLoader.new(options.load)

      announce "Sourcing dump into the #{loader.config['database']} db"
      loader.load

      success "Your #{loader.config['database']} database has now the data of #{options.load}."
    else
      announce 'Dumping the development database'
      Util.system! 'dumple development'
      success 'Successfully dumped the development database.'
    end

  else
    announce 'Dumping the database of ' + target
    dump_path = Geordi::Remote.new(target).dump

    if options.load
      loader = DumpLoader.new(dump_path)

      announce "Sourcing dump into the #{loader.config['database']} db"
      loader.load

      success "Your #{loader.config['database']} database has now the data of #{target}."
    end
  end

end
