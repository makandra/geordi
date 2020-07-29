desc 'rspec [FILES]', 'Run RSpec'
long_desc <<-LONGDESC
Example: `geordi rspec spec/models/user_spec.rb:13`

Runs RSpec with RSpec 1/2 detection and `bundle exec`
LONGDESC

def rspec(*files)
  if File.exist?('spec/spec_helper.rb')
    invoke_cmd 'bundle_install'
    invoke_cmd 'yarn_install'

    Interaction.announce 'Running specs'

    if Util.file_containing?('Gemfile', /parallel_tests/) && files.empty?
      Interaction.note 'All specs at once (using parallel_tests)'
      Util.system! Util.binstub('rake'), 'parallel:spec', fail_message: 'Specs failed.'

    else
      # tell which specs will be run
      if files.empty?
        files << 'spec/'
        Interaction.note 'All specs in spec/'
      else
        Interaction.note 'Only: ' + files.join(', ')
      end

      command = ['bundle exec']
      command << if File.exist?('script/spec')
        'spec -c' # RSpec 1
      elsif File.exist?('bin/rspec')
        'bin/rspec'
      else
        'rspec'
      end
      command << '-r rspec_spinner -f RspecSpinner::Bar' if Util.file_containing?('Gemfile', /rspec_spinner/)
      command << files.join(' ')

      puts
      Util.system! command.join(' '), fail_message: 'Specs failed.'
    end
  else
    Interaction.note 'RSpec not employed.'
  end
end
