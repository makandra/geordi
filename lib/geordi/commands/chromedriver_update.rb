desc 'chromedriver-update', 'Update the chromedriver'

long_desc <<-LONGDESC
Example: `geordi chromedriver_update`

This command will find and install the matching chromedriver for the currently installed Chrome.
LONGDESC

def chromedriver_update
  require 'geordi/chromedriver_updater'

  ChromedriverUpdater.new.run
end
