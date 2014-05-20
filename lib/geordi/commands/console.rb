desc 'console TARGET', 'Open a Rails console on a Capistrano deploy target or locally'
def console(target = 'development', *args)
  require 'geordi/remote'

  if target == 'development'
    announce 'Opening a local Rails console'

    Util.system! Util.console_command(target)

  else
    announce 'Opening a Rails console on ' + target

    Geordi::Remote.new(target).console
  end
end
