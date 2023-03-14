desc 'commit', 'Commit using a story title from Pivotal Tracker'
long_desc <<-LONGDESC
Example: `geordi commit`

Any extra arguments are forwarded to `git commit -m <message>`.

On the first execution we ask for your Pivotal Tracker API token. It will be
stored in `~/.config/geordi/global.yml`.

You can filter the stories by owner by adding `pivotal_tracker_owner_filter: <your pivotal tracker username>` to your `~/.config/geordi/global.yml`.
This filter can be skipped with the `-o` option.
LONGDESC

option :skip_owner_filter, aliases: '-o', type: :boolean, desc: 'Don´t filter stories by owner'

def commit(*git_args)
  require 'geordi/gitpt'
  Gitpt.new(skip_owner_filter: options.skip_owner_filter).run_commit(git_args)
end
