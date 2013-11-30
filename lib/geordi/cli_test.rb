module Geordi
  class CLITest < Thor
    
    default_task :all

    desc 'all', 'Run all employed tests'
    def all
      args.shift # remove the 'all' command itself from its args
      Rake::Task['geordi:tests'].invoke
    end

    desc 'rspec', 'Run (R)Spec'
    def rspec(*args)
      args.shift # remove the 'rspec' command itself from its args
      Rake::Task['geordi:spec'].invoke(args)
    end
    
    desc 'cucumber', 'Run Cucumber features'
    def cucumber(*args)
      args.shift # remove the 'cucumber' command itself from its args
      Rake::Task['geordi:features'].invoke(args)
    end

  end
end
