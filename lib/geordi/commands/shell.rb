# This method has a triple 'l' because :shell is a Thor reserved word. However,
# it can still be called with `geordi shell` :)

desc 'shell TARGET', 'Open a shell on a Capistrano deploy target'
def shelll(target, *args)
  require 'geordi/remote'

  Geordi::Remote.new(target).shell
end
