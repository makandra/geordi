desc 'unit', 'Run Test::Unit'
def unit
  if File.exists?('test/test_helper.rb')
    invoke_cmd 'bundle_install'
    invoke_cmd 'yarn_install'

    announce 'Running Test::Unit'
    Util.system! 'bundle exec rake test'
  else
    note 'Test::Unit not employed.'
  end
end
