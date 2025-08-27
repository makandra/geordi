require 'geordi/linear_client'
require 'geordi/git'

desc 'branch', 'Check out a feature branch based on a Linear issue'
long_desc <<-LONGDESC
Example: `geordi branch`

On the first execution we ask for your Linear API token. It will be
stored in `~/.config/geordi/global.yml`.
LONGDESC

option :from_master, aliases: %w[-m --from-main], type: :boolean, desc: 'Branch from master instead of the current branch'

def branch
  issue = LinearClient.new.choose_issue

  local_branches = Git.local_branch_names
  matching_local_branch = local_branches.find { |branch_name| branch_name == issue['branchName'] }
  matching_local_branch ||= local_branches.find { |branch_name| branch_name.include? issue['identifier'].to_s }

  if matching_local_branch
    Util.run! ['git', 'checkout', matching_local_branch]
  else
    default_branch = Git.default_branch
    Util.run! ['git', 'checkout', default_branch] if options.from_master
    Util.run! ['git', 'checkout', '-b', issue['branchName']]
  end

  Hint.did_you_know [
    :commit,
    [:branch, :from_master],
  ]
end
