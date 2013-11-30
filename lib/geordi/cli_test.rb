module Geordi
  class CLITest < Thor
    
    default_task :all

    desc 'all', 'Run all employed tests'
    def all
      Rake::Task['geordi:tests'].invoke
    end

    desc 'spec', 'Run (R)Spec'
    def spec(*args)
      Rake::Task['geordi:spec'].invoke(args)
    end

  end
end
