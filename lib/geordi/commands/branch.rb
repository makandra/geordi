desc 'branch', 'Check out a feature branch based on a story from Pivotal Tracker'
long_desc <<-LONGDESC
Example: `geordi branch`

On the first execution we ask for your Pivotal Tracker API token. It will be
stored in `~/.config/geordi/global.yml`.
LONGDESC

def branch
  require 'geordi/gitpt'
  Gitpt.new.run_branch
end
