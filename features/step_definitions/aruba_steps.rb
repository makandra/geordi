if Aruba::VERSION < '1.0.0'
  require 'aruba/cucumber/core'
end
require 'aruba/generators/script_file'

Then /^the last (\d) lines of (output|stderr|stdout) should contain: "(.+?)"$/ do |line_count, channel, expected_output|
  output = case channel
  when 'output'
    all_output
  when 'stderr'
    all_stderr
  when 'stdout'
    all_stdout
  end

  last_lines = last_lines_from_output(output, line_count)
  expect(last_lines).to include(expected_output)
end

Then /^the last (\d) lines of (output|stderr|stdout) should contain:$/ do |line_count, channel, expected_output|
  output = case channel
  when 'output'
    all_output
  when 'stderr'
    all_stderr
  when 'stdout'
    all_stdout
  end

  last_lines = last_lines_from_output(output, line_count)
  expect(last_lines).to include(expected_output)
end


module ArubaHelper
  def last_lines_from_output(output, line_count)
    sanitized_array = sanitize_text(output).split(/\n/)
    filtered = sanitized_array.reject(&:empty?)
    filtered.last(line_count.to_i).join
  end
end

World(ArubaHelper)

