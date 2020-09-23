desc 'chromedriver-update', 'Update the chromedriver'
long_desc <<-LONGDESC
Example: `geordi chromedriver_update`

This command will find and install the matching chromedriver for the currently
installed Chrome.

Setting `auto_update_chromedriver` to `true` in your global Geordi config file 
(`~/.config/geordi/global.yml`), will automatically update chromedriver before 
cucumber tests, in case Chrome and chromedriver versions don't match
LONGDESC

option :quiet_if_matching, type: :boolean, default: false,
  desc: 'Suppress notification if chromedriver and chrome versions match'

def chromedriver_update
  require 'geordi/chromedriver_updater'

  ChromedriverUpdater.new.run(options)
end
