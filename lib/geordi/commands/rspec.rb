desc 'rspec [FILES]', 'Run RSpec'
long_desc <<-LONGDESC
Example: `geordi rspec spec/models/user_spec.rb:13`

Runs RSpec with version 1/2 support, parallel_tests detection and `bundle exec`.

In order to limit processes in a parallel run, you can set an environment
variable like this: `PARALLEL_TEST_PROCESSORS=6 geordi rspec`
LONGDESC

def rspec(*files)
  if File.exist?('spec/spec_helper.rb')
    require 'geordi/settings'

    settings = Geordi::Settings.new

    invoke_geordi 'bundle_install'
    invoke_geordi 'yarn_install'
    if settings.auto_update_chromedriver && Util.gem_available?('selenium-webdriver')
      invoke_geordi 'chromedriver_update', quiet_if_matching: true
    end

    Interaction.announce 'Running specs'

    if Util.file_containing?('Gemfile', /parallel_tests/) && files.empty?
      Interaction.note 'All specs at once (using parallel_tests)'
      Util.run!([Util.binstub_or_fallback('rake'), 'parallel:spec'], fail_message: 'Specs failed.')

    else
      # tell which specs will be run
      if files.empty?
        files << 'spec/'
        Interaction.note 'All specs in spec/'
      else
        Interaction.note 'Only: ' + files.join(', ')
      end

      command = if File.exist?('script/spec')
        ['bundle exec spec -c'] # RSpec 1
      else
        [Util.binstub_or_fallback('rspec')]
      end
      command << '-r rspec_spinner -f RspecSpinner::Bar' if Util.file_containing?('Gemfile', /rspec_spinner/)
      command << files.join(' ')

      puts
      Util.run!(command.join(' '), fail_message: 'Specs failed.')

      Hint.did_you_know [
        :cucumber
      ]
    end
  else
    Interaction.note 'RSpec not employed.'
  end
end
