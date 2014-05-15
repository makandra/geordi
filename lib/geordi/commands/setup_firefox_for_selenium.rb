desc 'setup_firefox_for_selenium', '[sic]'
def setup_firefox_for_selenium(version)
  require 'geordi/firefox_for_selenium'

  Geordi::FirefoxForSelenium.install(version)
end
