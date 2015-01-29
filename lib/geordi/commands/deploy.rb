desc 'deploy', 'Guided deployment'
def deploy
  ENV['PAGER'] = 'cat'

  master_branch = prompt 'master branch:', 'master'
  production_branch = prompt 'production branch:', 'production'
  production_stage = prompt 'production capistrano stage:', 'production'

  announce "Checking if your #{master_branch} is up to date"
  diff_size = `git fetch && git diff #{master_branch} origin/#{master_branch} | wc -l`.strip
  changes_size = `git status -s | wc -l`.strip

  if diff_size == '0' and changes_size == '0'
    note 'All good.'
  else
    fail "Your #{master_branch} is not the same as on origin or holds uncommitted changes. Fix that first."
  end

  announce "Checking what's on #{production_stage} right now..."
  Util.system! "git checkout #{production_branch} && git pull"

  announce "You are about to deploy the following commits from #{master_branch} to #{production_branch}:"
  Util.system! "git log #{production_branch}..#{master_branch} --oneline"

  if prompt('Go ahead with the deployment?', 'n', /y|yes/)
    capistrano_call = "cap #{production_stage} deploy:migrations"
    if file_containing?('Gemfile', /capistrano/)
      capistrano_call = "bundle exec #{capistrano_call}"
    end

    puts
    Util.system! "git merge #{master_branch} && git push && #{capistrano_call}"

    success 'Deployment complete.'
  else
    fail 'Deployment cancelled.'
  end

end
