if Aruba::VERSION < '1.0.0'
  require 'aruba/cucumber/core'
end
require 'aruba/generators/script_file'

Given 'I ignore previous output' do
  aruba.command_monitor.clear
end
