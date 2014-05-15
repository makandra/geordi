desc 'test', 'Run all employed tests'
def test
  invoke :with_rake
  invoke :unit
  invoke :rspec
  invoke :cucumber

  success 'Successfully ran tests.'
end
