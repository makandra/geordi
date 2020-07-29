desc 'unit', 'Run Test::Unit'
def unit
  if File.exist?('test/test_helper.rb')
    invoke_cmd 'bundle_install'
    invoke_cmd 'yarn_install'

    Interaction.announce 'Running Test::Unit'
    Util.system! Util.binstub('rake'), 'test'
  else
    Interaction.note 'Test::Unit not employed.'
  end
end
