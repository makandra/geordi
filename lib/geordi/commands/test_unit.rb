desc 'test_unit', 'Run Test::Unit'
def test_unit
  if File.exists?('test/test_helper.rb')
    invoke_cmd 'bundle_install'

    announce 'Running Test::Unit'
    Util.system! 'bundle exec rake test'
  else
    note 'Test::Unit not employed.'
  end
end
