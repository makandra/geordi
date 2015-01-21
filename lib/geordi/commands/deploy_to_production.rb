desc 'deploy-to-production', '[sic]'
def deploy_to_production
  ENV['PAGER'] = 'cat'

  master_branch = prompt('master branch', 'master')
  production_branch = prompt('production branch', 'production')
  production_stage = prompt('production capistrano stage', 'production')

  announce "Checking if your #{master_branch} is up to date"

  diff_size = call_or_fail("git fetch && git diff #{master_branch} origin/#{master_branch} | wc -l", true)
  changes_size = call_or_fail('git status -s | wc -l', true)

  if diff_size == '0' and changes_size == '0'
    note 'All good.'
  else
    fail "Your #{master_branch} is not the same as on origin or holds uncommitted changes. Fix that first."
  end

  announce "Checking what's on #{production_stage} right now..."

  call_or_fail "git checkout #{production_branch} && git pull"

  announce "You are about to deploy the following commits from #{master_branch} to #{production_branch}:"

  call_or_fail "git log #{production_branch}..#{master_branch} --oneline"

  if prompt('Go ahead with the deployment?', 'n').downcase == 'y'
    puts
    capistrano_call = "cap #{production_stage} deploy:migrations"
    if file_containing?('Gemfile', /capistrano/)
      capistrano_call = "bundle exec #{capistrano_call}"
    end
    call_or_fail("git merge #{master_branch} && git push && #{capistrano_call}")
    success 'Deployment complete.'
  else
    fail 'Deployment cancelled.'
  end

end

private

def call_or_fail(command, return_output = false)
  note_cmd command
  if return_output
    result = `#{command}`.to_s.strip
    $?.success? or fail "Error while calling #{command}: #{$?}"
  else
    result = system(command) or fail "Error while calling #{command}: #{$?}"
    puts
  end
  result
end

def prompt(message, default)
  print "#{message}"
  print " [#{default}]" if default
  print ": "
  input = $stdin.gets.strip
  if input.empty? && default
    input = default
  end
  input
end
