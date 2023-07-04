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

  Hint.did_you_know [
    :shelll,
    [:console, :select_server],
  ]

  if target == 'development'
    invoke_geordi 'bundle_install'
    invoke_geordi 'yarn_install'

    Interaction.announce 'Opening a local Rails console'

    command = Util.console_command(target)
    Util.run!(command)
  else
    Interaction.announce 'Opening a Rails console on ' + target

    Geordi::Remote.new(target).console(options)
  end
end
