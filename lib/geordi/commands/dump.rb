desc 'dump [TARGET]', 'Handle dumps'
long_desc <<-DESC
When called without arguments, will dump the development database.

When called with a capistrano deploy target (e.g. staging), will remotely dump
the specified database.
DESC

option :load, :aliases => ['-l'], :type => :boolean, :desc => 'Load a dump'

def dump(target = 'development', *args)
  require 'geordi/dump_loader'
  require 'geordi/remote'

  if target == 'development'
    announce 'Dumping the development database'
    Util.system! 'dumple development'

  else
    announce "Dumping the #{target} database"

    Geordi::Remote.new(target).dump
  end

  if options.load
    announce 'Sourcing dump into ' + development_db
    DumpLoader.new(args).execute!

    success "Your database is now sourced with a fresh #{target} dump."
  end
end
