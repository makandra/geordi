require 'geordi/linear_client'
require 'geordi/git'
require 'highline'

desc 'commit', 'Commit using an issue title from Linear'
long_desc <<-LONGDESC
Example: `geordi commit`

Any extra arguments are forwarded to `git commit -m <message>`.

On the first execution we ask for your Linear API token. It will be
stored in `~/.config/geordi/global.yml`.
LONGDESC

def commit(*git_args)

  Interaction.warn <<~WARNING unless Git.staged_changes?
        No staged changes. Will create an empty commit.
      WARNING

  linear_client = LinearClient.new
  highline = HighLine.new

  issue = linear_client.issue_from_branch || linear_client.choose_issue
  title = "[#{issue['identifier']}] #{issue['title']}"
  description = "Issue: #{issue['url']}"
  extra = highline.ask("\nAdd an optional message").strip
  title << ' - ' << extra if extra != ''
  Util.run!(['git', 'commit', '--allow-empty', '-m', title, '-m', description, *git_args])

  Hint.did_you_know [
    :branch,
    :deploy,
  ]
end
