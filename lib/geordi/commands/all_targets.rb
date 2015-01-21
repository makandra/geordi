desc 'all_targets', 'Run a capistrano command on all deploy targets'
def all_targets(*args)
  targets = Dir['config/deploy/*.rb'].map { |file| File.basename(file, '.rb') }.sort

  note 'Found the following deploy targets:'
  puts targets
  puts

  print 'Continue? [yN] '
  exit unless $stdin.gets =~ /[yes]+/

  targets << nil if targets.empty? # default target
  targets.each do |stage|
    announce 'Target: ' + (stage || '(default)')

    command = "bundle exec cap #{stage} " + args.join(' ')
    note_cmd command

    Util.system!(command, :fail_message => 'Capistrano failed. Have a look!')
  end

end
