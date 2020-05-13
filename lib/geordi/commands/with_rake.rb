desc 'with-rake', 'Run tests with `rake`', hide: true
def with_rake
  if Util.file_containing?('Rakefile', /^task.+default.+(spec|test|feature)/)
    invoke_cmd 'bundle_install'
    invoke_cmd 'yarn_install'

    Interaction.announce 'Running tests with `rake`'
    Util.system! 'rake'
  else
    Interaction.note '`rake` does not run tests.'
    :did_not_perform
  end
end
