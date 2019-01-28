desc 'rspec [FILES]', 'Run RSpec'
long_desc <<-LONGDESC
Example: `geordi rspec spec/models/user_spec.rb:13`

Runs RSpec as you want: with RSpec 1/2 detection, `bundle exec`, rspec_spinner
detection, etc.
LONGDESC

def rspec(*files)
  if File.exists?('spec/spec_helper.rb')
    invoke_cmd 'bundle_install'

    announce 'Running specs'

    if Util.file_containing?('Gemfile', /parallel_tests/) and files.empty?
      note 'All specs at once (using parallel_tests)'
      Util.system! 'bundle exec rake parallel:spec', :fail_message => 'Specs failed.'

    else
      # tell which specs will be run
      if files.empty?
        files << 'spec/'
        note 'All specs in spec/'
      else
        note 'Only: ' + files.join(', ')
      end

      command = ['bundle exec']
      command << if File.exists?('script/spec')
        'spec -c' # RSpec 1
      elsif File.exists?('bin/rspec')
        'bin/rspec'
      else
        'rspec'
      end
      command << '-r rspec_spinner -f RspecSpinner::Bar' if Util.file_containing?('Gemfile', /rspec_spinner/)
      command << files.join(' ')

      puts
      Util.system! command.join(' '), :fail_message => 'Specs failed.'
    end
  else
    note 'RSpec not employed.'
  end
end
