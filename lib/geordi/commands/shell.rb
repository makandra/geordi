desc 'shell TARGET', 'Open a shell on a Capistrano deploy target'
long_desc <<-LONGDESC
Example: `geordi shell production`

Lets you select the server to connect to from a menu when called with `--select-server` or the alias `-s`:

    geordi shell production -s

If you already know the number of the server you want to connect to, just pass it along:

    geordi shell production -s2
LONGDESC

option :select_server, type: :string, aliases: '-s'

# This method has a triple 'l' because :shell is a Thor reserved word. However,
# it can still be called with `geordi shell` :)
def shelll(target, *_args)
  require 'geordi/remote'

  Interaction.announce 'Opening a shell on ' + target
  Geordi::Remote.new(target).shell(options)
end
