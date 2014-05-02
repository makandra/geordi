require 'thor'
require 'geordi/cuc'
require 'geordi/cli/util'

module Geordi
  class Test < Thor
    include Geordi::Util

    namespace 'test'
    default_command :all

    desc 'all', 'Run all employed tests'
    def all
      invoke :with_rake
      invoke :unit
      invoke :rspec
      invoke :cucumber

      success 'Successfully ran tests.'
    end

    desc 'rspec', 'Run RSpec'
    long_desc <<-LONGDESC
    Runs RSpec as you want: RSpec 1&2 detection, bundle exec, rspec_spinner
    detection.
    LONGDESC
    def rspec(*files)
      if File.exists?('spec/spec_helper.rb')
        invoke :bundle_install

        announce 'Running specs'

        if file_containing?('Gemfile', /parallel_tests/) and files.empty?
          note 'All specs at once (using parallel_tests)'
          system! 'bundle exec rake parallel:spec'

        else
          # tell which specs will be run
          if files.empty?
            files << 'spec/'
            note 'All specs in spec/'
          else
            note 'Only: ' + files.join(', ')
          end

          command = ['bundle exec']
          # differentiate RSpec 1/2
          command << (File.exists?('script/spec') ? 'spec -c' : 'rspec')
          command << '-r rspec_spinner -f RspecSpinner::Bar' if file_containing?('Gemfile', /rspec_spinner/)
          command << files.join(' ')

          puts
          system! command.join(' ')
        end
      else
        note 'RSpec not employed.'
      end
    end

    desc 'cucumber', 'Run Cucumber features'
    long_desc <<-LONGDESC
    Runs Cucumber as you want: bundle exec, cucumber_spinner detection,
    separate Firefox for Selenium, etc.
    LONGDESC
    def cucumber(*files)
      invoke :bundle_install

      if File.directory?('features')
        announce 'Running features'
        Geordi::Cucumber.new.run(files) or fail
      else
        note 'Cucumber not employed.'
      end
    end

    desc 'unit', 'Run Test::Unit'
    def unit
      if File.exists?('test/test_helper.rb')
        invoke :bundle_install

        announce 'Running Test::Unit'
        system! 'bundle exec rake test'
      else
        note 'Test::Unit not employed.'
      end
    end

    desc 'with_rake', 'Run tests with `rake`'
    def with_rake
      if file_containing?('Rakefile', /^task.+default.+(spec|test)/)
        invoke :bundle_install

        announce 'Running tests with `rake`'
        system! 'rake'
      else
        note '`rake` does not run tests.'
      end
    end

    # This task lives here to prevent code duplication. Actually it should live
    # in CLI – move it there if you know how to invoke it from this class.
    desc 'bundle_install', 'Run bundle install if required', :hide => true
    def bundle_install
      if File.exists?('Gemfile') and !system('bundle check &>/dev/null')
        announce 'Bundling'
        system! 'bundle install'
      end
    end

  end
end
