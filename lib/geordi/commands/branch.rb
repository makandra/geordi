desc 'branch', 'Check out a feature branch based on an issue from Linear'
long_desc <<-LONGDESC
Example: `geordi branch`

On the first execution we ask for your Linear API token and for your Git user initials. Both will be
stored in `~/.config/geordi/global.yml`.
LONGDESC

option :from_master, aliases: '-m', type: :boolean, desc: 'Branch from master instead of the current branch'

def branch
  require 'geordi/gitlinear'
  Gitlinear.new.run_branch(from_master: options.from_master)

  Hint.did_you_know [
    :commit,
    [:branch, :from_master],
  ]
end
