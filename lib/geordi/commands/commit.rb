desc 'commit', 'Commit using an issue title from Linear'
long_desc <<-LONGDESC
Example: `geordi commit`

Any extra arguments are forwarded to `git commit -m <message>`.

On the first execution we ask for your Linear API token. It will be
stored in `~/.config/geordi/global.yml`.
LONGDESC

def commit(*git_args)
  require 'geordi/gitlinear'
  Gitlinear.new.run_commit(git_args)

  Hint.did_you_know [
    :branch,
    :deploy,
  ]
end
