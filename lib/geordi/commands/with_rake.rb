desc 'with-rake', 'Run tests with `rake`', :hide => true
def with_rake
  if file_containing?('Rakefile', /^task.+default.+(spec|test|feature)/)
    invoke_cmd 'bundle_install'

    announce 'Running tests with `rake`'
    Util.system! 'rake'
  else
    note '`rake` does not run tests.'
    :did_not_perform
  end
end
