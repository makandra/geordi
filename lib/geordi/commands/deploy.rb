desc 'deploy [STAGE]', 'Guided deployment across branches'
long_desc <<-LONGDESC
Example: `geordi deploy` or `geordi deploy p[roduction]` or `geordi deploy --current-branch`

Merge, push and deploy with a single command! **It always tells what it will do
before it does it.** There are different scenarios where this command is handy:

- *Production deploy:* From the master branch, run `geordi deploy production`.
  This will merge `master` to `production`, push and deploy to production.

- *Feature branch deploy:* From a feature branch, run `geordi deploy staging`.
  This will merge the feature branch to `master`, push and deploy to staging.

  To deploy a feature branch directly without merging, run
  `geordi deploy --current-branch`. This feature depends on the environment
  variable `DEPLOY_BRANCH` to be picked up in the respective deploy file.

- *Simple deploy:* If the source branch matches the target branch, merging will
  be skipped.

Calling the command without arguments will infer the target stage from the
current branch and fall back to master/staging.

Finds available Capistrano stages by their prefix, e.g. `geordi deploy p` will
deploy production, `geordi deploy mak` will deploy a `makandra` stage if there
is a file config/deploy/makandra.rb.

When your project is running Capistrano 3, deployment will use `cap deploy`
instead of `cap deploy:migrations`. You can force using `deploy` by passing the
-M option: `geordi deploy -M staging`.
LONGDESC

option :no_migrations, aliases: '-M', type: :boolean,
  desc: 'Run cap deploy instead of cap deploy:migrations'
option :current_branch, aliases: '-c', type: :boolean,
  desc: 'Set DEPLOY_BRANCH to the current branch during deploy'

def deploy(target_stage = nil)
  # Set/Infer default values
  branch_stage_map = { 'master' => 'staging', 'production' => 'production' }
  if target_stage && !Util.deploy_targets.include?(target_stage)
    # Target stage autocompletion from available stages
    target_stage = Util.deploy_targets.find { |t| t.start_with? target_stage }
    target_stage || Interaction.warn('Given deployment stage not found')
  end

  # Ask for required information
  target_stage ||= Interaction.prompt 'Deployment stage:', branch_stage_map.fetch(Util.current_branch, 'staging')
  if options.current_branch
    stage_file = "config/deploy/#{target_stage}.rb"
    Util.file_containing?(stage_file, 'DEPLOY_BRANCH') || Interaction.fail(<<-ERROR)
To deploy from the current branch, configure #{stage_file} to respect the
environment variable DEPLOY_BRANCH. Example:

set :branch, ENV['DEPLOY_BRANCH'] || 'master'
    ERROR

    source_branch = target_branch = Util.current_branch
  else
    source_branch = Interaction.prompt 'Source branch:', Util.current_branch
    target_branch = Interaction.prompt 'Deploy branch:', branch_stage_map.invert.fetch(target_stage, 'master')
  end

  merge_needed = (source_branch != target_branch)
  push_needed = merge_needed || `git cherry -v | wc -l`.strip.to_i > 0
  push_needed = false if Util.testing? # Hard to test

  Interaction.announce "Checking whether your #{source_branch} branch is ready" ############
  Util.system! "git checkout #{source_branch}"
  if (`git status -s | wc -l`.strip != '0') && !Util.testing?
    Interaction.warn "Your #{source_branch} branch holds uncommitted changes."
    Interaction.prompt('Continue anyway?', 'n', /y|yes/) || raise('Cancelled.')
  else
    Interaction.note 'All good.'
  end

  if merge_needed
    Interaction.announce "Checking what's in your #{target_branch} branch right now" #######
    Util.system! "git checkout #{target_branch} && git pull"
  end

  Interaction.announce 'You are about to:' #################################################
  Interaction.note "Merge branch #{source_branch} into #{target_branch}" if merge_needed
  if push_needed
    Interaction.note 'Push these commits:' if push_needed
    Util.system! "git --no-pager log origin/#{target_branch}..#{source_branch} --oneline"
  end
  Interaction.note "Deploy to #{target_stage}"
  Interaction.note "From current branch #{source_branch}" if options.current_branch

  if Interaction.prompt('Go ahead with the deployment?', 'n', /y|yes/)
    puts
    git_call = []
    git_call << "git merge #{source_branch}" if merge_needed
    git_call << 'git push' if push_needed

    invoke_cmd 'bundle_install'

    capistrano_call = "cap #{target_stage} deploy"
    capistrano_call << ':migrations' unless Util.gem_major_version('capistrano') == 3 || options.no_migrations
    capistrano_call = "bundle exec #{capistrano_call}" if Util.file_containing?('Gemfile', /capistrano/)
    capistrano_call = "DEPLOY_BRANCH=#{source_branch} #{capistrano_call}" if options.current_branch

    if git_call.any?
      Util.system! git_call.join(' && '), show_cmd: true
    end

    Util.system! capistrano_call, show_cmd: true

    Interaction.success 'Deployment complete.'
  else
    Util.system! "git checkout #{source_branch}"
    Interaction.fail 'Deployment cancelled.'
  end
end
