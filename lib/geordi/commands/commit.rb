desc 'commit', 'Commit using a story title from Pivotal Tracker'

long_desc <<-LONGDESC
Example: `geordi commit`

On the first execution we ask for your Pivotal Tracker API token. It will be
stored in `~/.gitpt`.
LONGDESC

def commit
  raise <<-TEXT if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.1')
Unsupported Ruby Version #{RUBY_VERSION}. `geordi commit` does not work with a Ruby version < 2.1.
  TEXT

  require 'geordi/gitpt'

  Gitpt.new.run
end

