desc 'rspec [FILES]', 'Run RSpec'
long_desc <<-LONGDESC
Example: `geordi rspec spec/models/user_spec.rb:13`

Runs RSpec with RSpec 1/2 support, parallel_tests detection and `bundle exec`.
LONGDESC

def rspec(*files)
  if File.exist?('spec/spec_helper.rb')
    invoke_geordi 'bundle_install'
    invoke_geordi 'yarn_install'

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
    end
  else
    Interaction.note 'RSpec not employed.'
  end
end
