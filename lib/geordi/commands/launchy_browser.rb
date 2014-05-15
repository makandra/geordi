desc '', ''
def launchy_browser(*args)
  require File.expand_path('../../cucumber', __FILE__)
  require 'launchy'

  Geordi::Cucumber.new.restore_env

  Launchy.open(args.first)
end
