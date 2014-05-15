desc 'launchy_browser', '?'
def launchy_browser(*args)
  require 'geordi/cucumber'
  require 'launchy'

  Geordi::Cucumber.new.restore_env

  Launchy.open(args.first)
end
