desc 'commit', 'Commit using a story titel from Pivotal Tracker'
def commit
  require File.expand_path('../../gitpt', __FILE__)

  Geordi::Gitpt.new.run
end
