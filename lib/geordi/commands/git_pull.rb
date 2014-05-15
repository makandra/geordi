desc 'git_pull', 'Perform git pull', :hide => true
def git_pull
  announce 'Updating repository'
  note 'git pull'
  system! 'git pull'
end
