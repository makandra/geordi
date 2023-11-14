desc 'shell TARGET', 'Open a shell on a Capistrano deploy target'
long_desc <<-LONGDESC
Example: `geordi shell production`

Selecting the server: `geordi shell staging -s` shows a menu with all available
servers. When passed a number, directly connects to the selected server.
LONGDESC

# This option is duplicated in console.rb
option :select_server, type: :string, aliases: '-s', banner: '[SERVER_NUMBER]',
  desc: 'Select a server to connect to'

# This method has a triple 'l' because :shell is a Thor reserved word. However,
# it can still be called with `geordi shell` :)
def shelll(target, *_args)
  require 'geordi/remote'

  Hint.did_you_know [
    :console,
    'You only need to type the unique prefix of a command to run it. `geordi sh` will work as well.',
  ]

  Interaction.announce 'Opening a shell on ' + target
  Geordi::Remote.new(target).shell(options)
end
