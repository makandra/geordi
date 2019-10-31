desc 'chromedriver-update', 'Update the chromedriver'

long_desc <<-LONGDESC
Example: `geordi chromedriver_update`

This command will find and install the matching chromedriver for the currently installed Chrome.
LONGDESC

def chromedriver_update
  require 'geordi/chromedriver_updater'

  # Ruby 1.9.3 introduces #capture3 in open3
  supported_ruby_version = '1.9.2'

  # We do not want to backport this command to Ruby 1.8.7, a user can just use a newer Ruby version to run it. For all
  # other commands it still is necessary to have a proper Ruby 1.8.7 support.
  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new(supported_ruby_version)
    raise("Unsupported ruby version #{RUBY_VERSION}, please use at least #{supported_ruby_version} to run this command!")
  end

  ChromedriverUpdater.new.run
end
