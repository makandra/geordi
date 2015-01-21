desc 'setup-firefox-for-selenium VERSION', 'Install a special firefox for running Selenium tests'
def setup_firefox_for_selenium(version)
  require 'geordi/firefox_for_selenium'

  Geordi::FirefoxForSelenium.install(version)
end
