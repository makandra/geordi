desc 'with-firefox-for-selenium COMMAND', 'Run a command with firefox for selenium set up'
def with_firefox_for_selenium(*command)
  note 'Setting up Firefox for Selenium ...'
  require 'geordi/cucumber'
  Cucumber.new.setup_vnc
  FirefoxForSelenium.setup_firefox
  puts

  note_cmd command.join
  Util.system! *command
end
