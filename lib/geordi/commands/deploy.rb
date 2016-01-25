desc 'deploy [STAGE]', 'Guided deployment across branches'
long_desc <<-LONGDESC
Example: `geordi deploy production`

Merge, push and deploy with a single command! There are several scenarios where
this command comes in handy:

1) Production deploy. From the master branch, run `geordi deploy production`.
   This will merge `master` to `production`, push and deploy to production.

2) Feature branch deploy. From the feature branch, run `geordi deploy staging`.
   This will merge the feature branch to `master`, push and deploy to staging.

3) Simple deploy. If the source branch matches the target branch, merging will
   be skipped.

Calling the command without arguments will infer the target stage from the
current branch and fall back to master/staging.

When your project does not have a `deploy:migrations` task, this command will
run `cap deploy` instead when called with `-M`: `geordi deploy -M staging`.
LONGDESC

option :no_migrations, :aliases => '-M', :type => :boolean,
  :desc => 'Run cap deploy instead of cap deploy:migrations'

def deploy(target_stage = nil)
  # Set/Infer default values
  branch_stage_map = { 'master' => 'staging', 'production' => 'production'}
  proposed_stage = target_stage || branch_stage_map.fetch(Util.current_branch, 'staging')

  target_stage = prompt 'Deployment capistrano stage:', proposed_stage
  source_branch = prompt 'Source branch:', Util.current_branch
  target_branch = prompt 'Deploy branch:', branch_stage_map.invert.fetch(target_stage, 'master')

  merge_needed = (source_branch != target_branch)

  announce "Checking whether your #{source_branch} branch is ready"
  diff_size = `git fetch && git diff #{source_branch} origin/#{source_branch} | wc -l`.strip
  changes_size = `git status -s | wc -l`.strip

  if diff_size != '0'
    fail "Your #{source_branch} branch is not the same as on origin. Fix that first."
  elsif changes_size != '0'
    fail "Your #{source_branch} branch holds uncommitted changes. Fix that first."
  else
    note 'All good.'
  end

  if merge_needed
    announce "Checking what's in your #{target_branch} branch right now ..."
    Util.system! "git checkout #{target_branch} && git pull"
  end

  announce "You are about to #{'merge & ' if merge_needed}push & deploy the following commits"
  note "From branch #{source_branch}"
  note "Merge into branch #{target_branch}" if merge_needed
  note "Deploy to #{target_stage}"
  Util.system! "git --no-pager log origin/#{target_branch}..#{source_branch} --oneline"

  if prompt('Go ahead with the deployment?', 'n', /y|yes/)
    cap3 = file_containing?('Capfile', 'capistrano/setup')
    capistrano_call = "cap #{target_stage} deploy"
    capistrano_call << ':migrations' unless cap3 || options.no_migrations
    capistrano_call = "bundle exec #{capistrano_call}" if file_containing?('Gemfile', /capistrano/)

    puts
    command = "git push && #{capistrano_call}"
    command = "git merge #{source_branch} && " << command if merge_needed
    Util.system! command, :show_cmd => true

    success 'Deployment complete.'
  else
    fail 'Deployment cancelled.'
  end

end
