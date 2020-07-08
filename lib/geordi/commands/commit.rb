desc 'commit', 'Commit using a story title from Pivotal Tracker'

long_desc <<-LONGDESC
Example: `geordi commit`

Any extra arguments are forwarded to `git commit -m <message>`.

If there are no staged changes, prints a warning but will continue to create
an empty commit.

On the first execution we ask for your Pivotal Tracker API token. It will be
stored in `~/.config/geordi/global.yml`.
LONGDESC

def commit(*git_args)
  raise <<-TEXT if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.1')
Unsupported Ruby Version #{RUBY_VERSION}. `geordi commit` requires Ruby 2.1+.
  TEXT

  require 'geordi/gitpt'

  Gitpt.new.run(git_args)
end
