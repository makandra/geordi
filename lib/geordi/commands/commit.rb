desc 'commit', 'Commit using a story title from Pivotal Tracker'
def commit
  require 'geordi/gitpt'

  Gitpt.new.run
end

