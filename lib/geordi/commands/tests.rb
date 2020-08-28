desc 'tests', 'Run all employed tests'
def tests
  rake_result = invoke_geordi 'with_rake'

  # Since `rake` usually is configured to run all tests, only run them if `rake`
  # did not perform
  if rake_result == :did_not_perform
    invoke_geordi 'unit'
    invoke_geordi 'rspec'
    invoke_geordi 'cucumber'
  end

  Interaction.success 'Successfully ran tests.'
end
