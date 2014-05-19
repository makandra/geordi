# This method has a triple 'l' because :shell is a Thor reserved word. However,
# it can still be called with `geordi shell` :)

desc 'shell TARGET', 'Open a shell on a Capistrano deploy target'
def shelll(target, *args)
  require 'geordi/remote'

  ENV['BUNDLE_BIN_PATH'] = 'Trick capistrano safeguard in deploy.rb into believing bundler is present by setting this variable.'
  remote = Geordi::Remote.new(target)
  remote.shell
end
