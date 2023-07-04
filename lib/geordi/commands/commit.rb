desc 'commit', 'Commit using a story title from Pivotal Tracker'
long_desc <<-LONGDESC
Example: `geordi commit`

Any extra arguments are forwarded to `git commit -m <message>`.

On the first execution we ask for your Pivotal Tracker API token. It will be
stored in `~/.config/geordi/global.yml`.
LONGDESC

def commit(*git_args)
  require 'geordi/gitpt'
  Gitpt.new.run_commit(git_args)

  Hint.did_you_know [
    :branch
  ]
end
