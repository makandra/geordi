desc 'unit', 'Run Test::Unit'
long_desc <<-LONGDESC
Supports `parallel_tests`, binstubs and `bundle exec`.

In order to limit processes in a parallel run, you can set an environment
variable like this: `PARALLEL_TEST_PROCESSORS=6 geordi unit`
LONGDESC
def unit
  if File.exist?('test/test_helper.rb')
    invoke_geordi 'bundle_install'
    invoke_geordi 'yarn_install'

    Interaction.announce 'Running Test::Unit'

    if Util.file_containing?('Gemfile', /parallel_tests/)
      Interaction.note 'All unit tests at once (using parallel_tests)'
      Util.run!([Util.binstub_or_fallback('rake'), 'parallel:test'], fail_message: 'Test::Unit failed.')
    else
      Util.run!([Util.binstub_or_fallback('rake'), 'test'], fail_message: 'Test::Unit failed.')
    end
  else
    Interaction.note 'Test::Unit not employed.'
  end
end
