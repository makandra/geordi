desc 'dump', 'Handle dumps'

option :load, :aliases => ['-l'], :type => :boolean

def dump(*args)
  require 'geordi/dump_loader'

  if options.load
    DumpLoader.new(args).execute!
  end
end
