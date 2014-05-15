desc 'test', 'Run all employed tests'
def test
  puts

  invoke 'with_rake'
  invoke 'test_unit'
  invoke 'rspec'
  invoke 'cucumber'

  success 'Successfully ran tests.'
end
