desc 'with_rake', 'Run tests with `rake`'
def with_rake
  if file_containing?('Rakefile', /^task.+default.+(spec|test)/)
    invoke 'bundle_install'

    announce 'Running tests with `rake`'
    system! 'rake'
  else
    note '`rake` does not run tests.'
  end
end
