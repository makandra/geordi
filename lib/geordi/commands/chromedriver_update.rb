desc 'chromedriver-update', 'Update the chromedriver'
long_desc <<-LONGDESC
Example: `geordi chromedriver_update`

This command will find and install the matching chromedriver for the currently
installed Chrome.

Setting `auto_update_chromedriver` to `true` in your global Geordi config file
(`~/.config/geordi/global.yml`), will automatically update chromedriver before
cucumber tests if a newer chromedriver version is available.
LONGDESC

option :quiet_if_matching, type: :boolean, default: false, hide: true,
  desc: 'Suppress notification if chromedriver is already on the latest version'
option :exit_on_failure, type: :boolean, default: true, hide: true,
  desc: "Exit with status code 1, if an error occurs."

def chromedriver_update
  require 'geordi/chromedriver_updater'

  ChromedriverUpdater.new.run(options)

  Hint.did_you_know [
    'Geordi can automatically keep chromedriver up-to-date. See `geordi help chromedriver-update`.',
  ] unless options.quiet_if_matching
end
