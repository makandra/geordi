desc 'cucumber [FILES]', 'Run Cucumber features'
long_desc <<-LONGDESC
Example: `geordi cucumber features/authentication_feature:3`

Runs Cucumber as you want: with `bundle exec`, `cucumber_spinner` detection,
separate Firefox for Selenium, etc.
LONGDESC

option :verbose, :aliases => '-v', :type => :boolean, :desc => 'Print the testing command'

def cucumber(*files)
  require 'geordi/cucumber'

  invoke_cmd 'bundle_install'

  if File.directory?('features')
    announce 'Running features'
    Geordi::Cucumber.new.run(files, :verbose => options.verbose) or fail 'Features failed.'
  else
    note 'Cucumber not employed.'
  end
end
