desc 'test', 'Run all employed tests'
def test
  puts

  invoke_cmd 'with_rake'
  invoke_cmd 'test_unit'
  invoke_cmd 'rspec'
  invoke_cmd 'cucumber'

  success 'Successfully ran tests.'
end
