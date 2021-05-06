if Aruba::VERSION < '1.0.0'
  require 'aruba/cucumber/core'
end
require 'aruba/generators/script_file'

Given 'I ignore previous output' do
  aruba.command_monitor.clear
end

Then(/^(?:the )?output should contain '([^']*)' (\d) times?$/) do |expected,amount|
  console_output = aruba.command_monitor.all_output
  expect(console_output.scan(expected).length).to eq amount.to_i
end
