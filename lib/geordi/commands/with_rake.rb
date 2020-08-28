desc 'with-rake', 'Run tests with `rake`', hide: true
def with_rake
  if Util.file_containing?('Rakefile', /^task.+default.+(spec|test|feature)/)
    invoke_geordi 'bundle_install'
    invoke_geordi 'yarn_install'

    Interaction.announce 'Running tests with `rake`'
    Util.system! Util.binstub('rake')
  else
    Interaction.note '`rake` does not run tests.'
    :did_not_perform
  end
end
