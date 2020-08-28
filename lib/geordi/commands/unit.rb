desc 'unit', 'Run Test::Unit'
def unit
  if File.exist?('test/test_helper.rb')
    invoke_geordi 'bundle_install'
    invoke_geordi 'yarn_install'

    Interaction.announce 'Running Test::Unit'
    Util.run! Util.binstub('rake'), 'test'
  else
    Interaction.note 'Test::Unit not employed.'
  end
end
