desc 'capistrano COMMAND', 'Run a Capistrano command on all deploy targets'
long_desc <<-LONGDESC
Example: `geordi capistrano deploy`
LONGDESC

def capistrano(*args)
  targets = Dir['config/deploy/*.rb'].map { |file| File.basename(file, '.rb') }.sort

  Interaction.note 'Found the following deploy targets:'
  puts targets
  Interaction.prompt('Continue?', 'n', /y|yes/) || Interaction.fail('Cancelled.')

  targets << nil if targets.empty? # default target
  targets.each do |stage|
    Interaction.announce 'Target: ' + (stage || '(default)')

    command = "bundle exec cap #{stage} " + args.join(' ')
    Interaction.note_cmd command

    Util.run!(command, fail_message: 'Capistrano failed. Have a look!')
  end

  Hint.did_you_know [
    :deploy,
    :rake,
  ]
end
