desc 'console [TARGET]', 'Open a Rails console locally or on a Capistrano deploy target'
long_desc <<-LONGDESC
Local (development): `geordi console`

Remote: `geordi console staging`

Selecting the server: `geordi console staging -s` shows a menu with all available
servers. When passed a number, directly connects to the selected server.
LONGDESC

# This option is duplicated in shelll.rb
option :select_server, type: :string, aliases: '-s', banner: '[SERVER_NUMBER]',
  desc: 'Select a server to connect to'

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
