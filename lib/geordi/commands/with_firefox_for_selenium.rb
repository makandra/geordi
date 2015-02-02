desc 'with-firefox-for-selenium COMMAND', 'Run a command with firefox for selenium set up'
long_desc <<-LONGDESC
Example: `geordi with-firefox-for-selenium b cucumber`

Useful when you need Firefox for Selenium, but can't use the `geordi cucumber`
command.
LONGDESC

def with_firefox_for_selenium(*command)
  note 'Setting up Firefox for Selenium ...'
  require 'geordi/cucumber'
  Cucumber.new.setup_vnc
  FirefoxForSelenium.setup_firefox
  puts

  note_cmd command.join(' ')
  exec *command
end
