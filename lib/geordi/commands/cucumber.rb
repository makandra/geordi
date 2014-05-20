desc 'cucumber [FILES]', 'Run Cucumber features'
long_desc <<-LONGDESC
Runs Cucumber as you want: bundle exec, cucumber_spinner detection,
separate Firefox for Selenium, etc.
LONGDESC

def cucumber(*files)
  require 'geordi/cucumber'

  invoke_cmd 'bundle_install'

  if File.directory?('features')
    announce 'Running features'
    Geordi::Cucumber.new.run(files) or fail
  else
    note 'Cucumber not employed.'
  end
end
