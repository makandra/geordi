desc 'tests', 'Run all employed tests'
def tests
  rake_result = invoke_cmd 'with_rake'

  if rake_result == :did_not_perform
    # Since `rake` usually runs all tests, only run them here if `rake` did not
    # perform
    invoke_cmd 'unit'
    invoke_cmd 'rspec'
    invoke_cmd 'cucumber'
  end

  success 'Successfully ran tests.'
end
