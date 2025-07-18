desc 'console [TARGET]', 'Open a Rails console locally or on a Capistrano deploy target'
long_desc <<-LONGDESC
Local (development): `geordi console`

Remote: `geordi console staging`

Selecting the server: `geordi console staging -s` shows a menu with all available
servers. When passed a number, directly connects to the selected server.

IRB flags can be given as `irb_flags: '...'` in the global or local Geordi config file
(`~/.config/geordi/global.yml` / `./.geordi.yml`). If you define irb_flags in both files, the local config file will be
used. For IRB >=1.2 in combination with Ruby <3 geordi automatically sets the `--nomultiline` flag, to prevent slow
pasting. You can override this behavior by setting `--multiline` in the global config file or by defining `irb_flags` 
in the local config file. The latter will always turn off the automatic behavior, even if you don't set any values for 
the irb_flags key.

LONGDESC

# This option is duplicated in shelll.rb
option :select_server, type: :string, aliases: '-s', banner: '[SERVER_NUMBER]',
  desc: 'Select a server to connect to'

def console(target = 'development', *_args)
  require 'geordi/remote'

  Hint.did_you_know [
    :shelll,
    [:console, :select_server],
    'You only need to type the unique prefix of a command to run it. `geordi con` will work as well.',
  ]

  if target == 'development'
    invoke_geordi 'bundle_install'
    invoke_geordi 'yarn_install'

    Interaction.announce 'Opening a local Rails console'

    command = Util.console_command(target)
    # Exec has better behavior on Ctrl + C
    Util.run!(command, exec: true)
  else
    Interaction.announce 'Opening a Rails console on ' + target

    Geordi::Remote.new(target).console(options)
  end
end
