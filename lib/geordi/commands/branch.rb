desc 'branch', 'Check out a feature branch based on a story from Pivotal Tracker'
long_desc <<-LONGDESC
Example: `geordi branch`

On the first execution we ask for your Pivotal Tracker API token and for your Git user initials. Both will be
stored in `~/.config/geordi/global.yml`.

You can filter the stories by owner by adding `pivotal_tracker_owner_filter: <your pivotal tracker username>` to your `~/.config/geordi/global.yml`.
This filter can be skipped with the `-o` option.
LONGDESC

option :from_master, aliases: '-m', type: :boolean, desc: 'Branch from master instead of the current branch'
option :skip_owner_filter, aliases: '-o', type: :boolean, desc: 'Don´t filter stories by owner'

def branch
  require 'geordi/gitpt'
  Gitpt.new(skip_owner_filter: options.skip_owner_filter).run_branch(from_master: options.from_master)
end
