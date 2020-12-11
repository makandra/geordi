if Aruba::VERSION < '1.0.0'
  require 'aruba/cucumber/core'
end
require 'aruba/generators/script_file'

When(/^I run `([^`]*)` interactively$/) do |cmd|
  cmd = sanitize_text(cmd)
  @interactive = run_command(cmd)
  @processed_inputs = []
  @processed_outputs = []
end

Then(/^I should see a prompt "(.+?)"$/) do |prompt|
  @interactive.stop
  current_output = sanitize_text(@interactive.output)
  expect(current_output).to include_output_string(prompt)
end

When(/^I type "([^"]*)" and continue$/) do |input|
  @interactive.start
  @processed_inputs << input
  @processed_inputs.each do |step_input|
    type(unescape_text(step_input))
  end
end
