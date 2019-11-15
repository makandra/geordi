desc 'tests', 'Run all employed tests'
def tests
  rake_result = invoke_cmd 'with_rake'

  # Since `rake` usually is configured to run all tests, only run them if `rake`
  # did not perform
  if rake_result == :did_not_perform
    invoke_cmd 'unit'
    invoke_cmd 'rspec'
    invoke_cmd 'cucumber'
  end

  success 'Successfully ran tests.'
end
