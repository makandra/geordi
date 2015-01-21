# This method has a triple 'l' because :shell is a Thor reserved word. However,
# it can still be called with `geordi shell` :)

desc 'shell TARGET', 'Open a shell on a Capistrano deploy target'
long_desc <<-LONGDESC
Example: `geordi shell production`

Lets you select the server to connect to when called with `--select-server`:

    geordi shell production -s
LONGDESC

option :select_server, :default => false, :type => :boolean, :aliases => '-s'

def shelll(target, *args)
  require 'geordi/remote'

  announce 'Opening a shell on ' + target
  Geordi::Remote.new(target).shell(options)
end
