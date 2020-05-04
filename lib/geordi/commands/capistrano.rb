desc 'capistrano COMMAND', 'Run a capistrano command on all deploy targets'
long_desc <<-LONGDESC
Example: `geordi capistrano deploy`
LONGDESC

def capistrano(*args)
  targets = Dir['config/deploy/*.rb'].map { |file| File.basename(file, '.rb') }.sort

  note 'Found the following deploy targets:'
  puts targets
  prompt('Continue?', 'n', /y|yes/) || raise('Cancelled.')

  targets << nil if targets.empty? # default target
  targets.each do |stage|
    announce 'Target: ' + (stage || '(default)')

    command = "bundle exec cap #{stage} " + args.join(' ')
    note_cmd command

    Util.system!(command, fail_message: 'Capistrano failed. Have a look!')
  end
end
