desc 'security-update [STEP]', 'Support for performing security updates'
long_desc <<-LONGDESC
Preparation for security update: `geordi security-update`. Checks out production
and pulls.

After performing the update: `geordi security-update finish`. Switches branches,
pulls, pushes and deploys as required by our workflow.

This command tells what it will do before it does it. In detail:

1. Ask user if tests are green

2. Push production

3. Check out master and pull

4. Merge production and push in master

5. Deploy staging, if there is a staging environment

6. Ask user if deployment log is okay and staging application is still running

7. Deploy other stages

8. Ask user if deployment log is okay and application is still running on all stages

9. Inform user about the next (manual) steps
LONGDESC

def security_update(step = 'prepare')
  case step
  when 'prepare'
    Interaction.announce 'Preparing for security update'
    Interaction.warn 'Please read https://makandracards.com/makandra/1587 before applying security updates!'
    Interaction.note 'About to checkout production and pull.'
    Interaction.prompt('Continue?', 'y', /y|yes/) || Interaction.fail('Cancelled.')

    Util.run! 'git checkout production', show_cmd: true
    Util.run! 'git pull', show_cmd: true

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

    Interaction.note 'About to: push production, checkout & pull master, merge production, push master.'
    Interaction.prompt('Continue?', 'n', /y|yes/) || Interaction.fail('Cancelled.')

    Util.run! 'git push', show_cmd: true
    Util.run! 'git checkout master', show_cmd: true
    Util.run! 'git pull', show_cmd: true
    Util.run! 'git merge production', show_cmd: true
    Util.run! 'git push', show_cmd: true

    Interaction.announce 'Deployment'
    deploy = (Util.gem_major_version('capistrano') == 3) ? 'deploy' : 'deploy:migrations'

    all_deploy_targets = Util.deploy_targets
    Interaction.fail 'There are no deploy targets!' if all_deploy_targets.empty?

    if all_deploy_targets.include?('staging')
      Interaction.note 'There is a staging environment.'
      Interaction.prompt('Deploy staging now?', 'y', /y|yes/) || Interaction.fail('Cancelled.')

      Interaction.announce 'Deploy staging'
      Util.run! "bundle exec cap staging #{deploy}", show_cmd: true

      Interaction.prompt('Is the deployment log okay and the application is still running on staging?', 'y', /y|yes/) || Interaction.fail('Please fix the deployment issues on staging before you continue.')
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
      Interaction.prompt('Deploy other stages now?', 'y', /y|yes/) || Interaction.fail('Cancelled.')

      deploy_targets_without_staging.each do |target|
        Interaction.announce "Deploy #{target}"
        Util.run! "bundle exec cap #{target} #{deploy}", show_cmd: true
      end

      Interaction.prompt('Is the application still running on all other stages and the logs are okay?', 'y', /y|yes/) || Interaction.fail('Please fix the application immediately!')
    end

    Interaction.success 'Successfully pushed and deployed security update'
    puts
    Interaction.note 'Now send an email to customer and project lead, informing them about the update.'
    Interaction.note 'Do not forget to make a joblog on a security budget, if available.'
  end
end
