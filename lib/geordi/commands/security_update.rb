desc 'security-update [STEP]', 'Support for performing security updates'
long_desc <<-LONGDESC
Preparation for security update: `geordi security-update`

After performing the update: `geordi security-update finish`

Switches branches, pulls, pushes and deploys as required by our workflow. Tells
what it will do before it does it.
LONGDESC

def security_update(step = 'prepare')
  case step
  when 'prepare'
    Interaction.announce 'Preparing for security update'
    Interaction.warn 'Please read https://makandracards.com/makandra/1587 before applying security updates!'
    Interaction.note 'About to checkout production and pull'
    Interaction.prompt('Continue?', 'y', /y|yes/) || Interaction.fail('Cancelled.')

    Util.system! 'git checkout production', show_cmd: true
    Util.system! 'git pull', show_cmd: true

    Interaction.success 'Successfully prepared for security update'
    puts
    Interaction.note 'Please apply the security update now and commit your changes.'
    Interaction.note 'When you are done, run `geordi security-update finish`.'


  when 'f', 'finish'
    # ensure everything is committed
    `git status --porcelain`.empty? || Interaction.fail('Please commit your changes before finishing the update.')

    Interaction.announce 'Finishing security update'
    Interaction.note 'Working directory clean.'
    Interaction.prompt('Have you successfully run all tests?', 'n', /y|yes/) || Interaction.fail('Please run tests first.')

    Interaction.note 'About to: push production, checkout & pull master, merge production, push master'
    Interaction.prompt('Continue?', 'n', /y|yes/) || Interaction.fail('Cancelled.')

    Util.system! 'git push', show_cmd: true
    Util.system! 'git checkout master', show_cmd: true
    Util.system! 'git pull', show_cmd: true
    Util.system! 'git merge production', show_cmd: true
    Util.system! 'git push', show_cmd: true

    Interaction.announce 'Deploying all targets'
    deploy = (Util.gem_major_version('capistrano') == 3) ? 'deploy' : 'deploy:migrations'
    invoke_cmd 'capistrano', deploy

    Interaction.success 'Successfully pushed and deployed security update'
    puts
    Interaction.note 'Now send an email to customer and project lead, informing them about the update.'
    Interaction.note 'Do not forget to make a joblog on a security budget, if available.'
  end
end
