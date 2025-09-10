desc 'security-update [STEP]', 'Support for performing security updates'
long_desc <<-LONGDESC
Preparation for security update: `geordi security-update`. Checks out production
and pulls, and will tell each step before performing it.

Part two after performing the update: `geordi security-update finish`. Switches
branches, pulls, pushes and deploys as required by our workflow. This as well
will tell each step before performing it.
LONGDESC

def security_update(step = 'prepare')
  require 'geordi/git'

  master = Git.default_branch

  case step
  when 'prepare'
    Interaction.announce 'Preparing for security update'
    Interaction.warn 'Please read https://makandracards.com/makandra/1587 before applying security updates!'
    Interaction.note 'About to checkout production and pull.'
    Interaction.confirm_or_cancel

    Util.run!('git checkout production', show_cmd: true)
    Util.run!('git pull', show_cmd: true)

    Interaction.success 'Successfully prepared for security update'
    puts
    Interaction.note 'Please apply the security update now and commit your changes.'
    Interaction.note 'When you are done, run `geordi security-update finish`.'


  when 'f', 'finish'
    # ensure everything is committed
    if Util.testing?
      puts 'Util.run! git status --porcelain'
    else
      `git status --porcelain`.empty? || Interaction.fail('Please commit your changes before finishing the update.')
    end

    Interaction.announce 'Finishing security update'
    Interaction.note 'Working directory clean.'
    Interaction.prompt('Have you successfully run all tests?', 'n', /y|yes/) || Interaction.fail('Please run tests first.')

    Interaction.note "About to: push production, checkout & pull #{master}, merge production, push #{master}."
    Interaction.confirm_or_cancel

    Util.run!('git push', show_cmd: true)
    Util.run!("git checkout #{master}", show_cmd: true)
    Util.run!('git pull', show_cmd: true)
    Util.run!('git merge production', show_cmd: true)
    Util.run!('git push', show_cmd: true)

    Interaction.announce 'Deployment'
    deploy = (Util.gem_major_version('capistrano') == 3) ? 'deploy' : 'deploy:migrations'

    all_deploy_targets = Util.deploy_targets
    Interaction.fail 'There are no deploy targets!' if all_deploy_targets.empty?

    if all_deploy_targets.include?('staging')
      Interaction.note 'There is a staging environment.'
      Interaction.confirm_or_cancel('Deploy staging now?')

      Interaction.announce 'Deploy staging'
      Util.run! "bundle exec cap staging #{deploy}", show_cmd: true

      Interaction.confirm_or_cancel('Is the deployment log okay and is the application still running on staging?', 'Please fix the deployment issues on staging before you continue.', default: 'n')
    else
      Interaction.note 'There is no staging environment.'
    end

    deploy_targets_without_staging = all_deploy_targets.select { |target| target != 'staging' }

    if deploy_targets_without_staging.empty?
      Interaction.note 'There are no other stages.'
    else
      puts
      Interaction.note 'Found the following other stages:'
      puts deploy_targets_without_staging
      puts
      Interaction.confirm_or_cancel('Deploy other stages now?')

      deploy_targets_without_staging.each do |target|
        Interaction.announce "Deploy #{target}"
        Util.run!("bundle exec cap #{target} #{deploy}", show_cmd: true)
      end

      Interaction.confirm_or_cancel('Are *all* the deployment logs okay and is the application still running on *all* other stages?', 'Please fix the application immediately!', default: 'n')
    end

    Interaction.success 'Successfully pushed and deployed security update'
    puts
    Interaction.note 'Now send an email to customer and project lead, informing them about the update.'
    Interaction.note 'Do not forget to make a joblog on a security budget, if available.'
  else
    Interaction.fail "Unsupported step #{step.inspect}"
  end
end
