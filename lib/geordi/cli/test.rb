module Geordi
  class Test < Thor

    package_name 'test'

    default_command :all

    desc 'all', 'Run all employed tests'
    def all
      Rake::Task['geordi:spec'].invoke
      Rake::Task['geordi:features'].invoke
      Rake::Task['geordi:rake_test'].invoke

      success 'Successfully ran tests.'
    end

    desc 'rspec', 'Run (R)Spec'
    long_desc <<-LONGDESC
    Runs RSpec as you want: RSpec 1/2 detection, bundle exec, rspec_spinner
    detection, etc.
    LONGDESC
    def rspec(*args)
      Rake::Task['geordi:spec'].invoke(args)
    end

    desc 'cucumber', 'Run Cucumber features'
    long_desc <<-LONGDESC
    Runs Cucumber as you want: bundle exec, cucumber_spinner detection,
    separate Firefox for Selenium, etc.
    LONGDESC
    def cucumber(*args)
      Rake::Task['geordi:features'].invoke(args)
    end

  end
end
