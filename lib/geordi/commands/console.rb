desc 'console [TARGET]', 'Open a Rails console locally or on a Capistrano deploy target'
long_desc <<-LONGDESC
Open a local Rails console: `geordi console`

Open a Rails console on `staging`: `geordi console staging`

Lets you select the server to connect to from a menu when called with `--select-server` or the alias `-s`:

    geordi console staging -s

If you already know the number of the server you want to connect to, just pass it along:

    geordi console staging -s2
LONGDESC


option :select_server, type: :string, aliases: '-s'

def console(target = 'development', *_args)
  require 'geordi/remote'

  if target == 'development'
    invoke_cmd 'yarn_install'

    Interaction.announce 'Opening a local Rails console'

    Util.system! Util.console_command(target)
  else
    Interaction.announce 'Opening a Rails console on ' + target

    Geordi::Remote.new(target).console(options)
  end
end
