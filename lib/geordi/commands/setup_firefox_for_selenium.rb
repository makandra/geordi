desc 'setup_firefox_for_selenium', '[sic]'
def setup_firefox_for_selenium(version)
  require File.expand_path('../../firefox_for_selenium', __FILE__)

  Geordi::FirefoxForSelenium.install(version)
end
