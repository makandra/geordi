desc 'commit', 'Commit using a story title from Pivotal Tracker'

long_desc <<-LONGDESC
Example: `geordi commit`

On the first execution we ask for your Pivotal Tracker API token. It will be
stored in `~/.gitpt`.
LONGDESC

def commit
  require 'geordi/gitpt'

  Gitpt.new.run
end

