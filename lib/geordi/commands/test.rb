desc 'tests', 'Run all employed tests'
def tests
  invoke_cmd 'with_rake'
  invoke_cmd 'unit'
  invoke_cmd 'rspec'
  invoke_cmd 'cucumber'

  success 'Successfully ran tests.'
end
