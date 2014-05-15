desc '', ''
def launchy_browser(*args)
  require File.join(File.dirname(__FILE__), '../lib/geordi/cuc')

  require 'rubygems'
  require 'launchy'

  Geordi::Cucumber.new.restore_env

  Launchy.open(args.first)
end
