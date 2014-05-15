desc 'dump', 'Handle dumps'
option :load, :aliases => ['-l'], :type => :boolean
def dump(*args)
  require File.expand_path('../../dump_loader', __FILE__)

  if options.load
    DumpLoader.new(args).execute!
  end
end
