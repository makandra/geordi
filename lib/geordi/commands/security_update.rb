desc 'security-update [STEP]', 'Support for performing security updates'
long_desc <<-LONGDESC
Preparation for security update: `geordi security-update`

After performing the update: `geordi security-update finish`

Switches branches, pulls, pushes and deploys as required by our workflow. Tells
what it will do before it does it.
LONGDESC

def security_update(step='prepare')
  case step
  when 'prepare'
    announce 'Preparing for security update'
    warn 'Please read https://makandracards.com/makandra/1587 before applying security updates!'
    note 'About to checkout production and pull'
    prompt('Continue?', 'y', /y|yes/) or fail 'Cancelled.'

    Util.system! 'git checkout production', :show_cmd => true
    Util.system! 'git pull', :show_cmd => true

    success 'Successfully prepared for security update'
    puts
    note 'Please apply the security update now and commit your changes.'
    note 'When you are done, run `geordi security-update finish`.'


  when 'f', 'finish'
    # ensure everything is committed
    `git status --porcelain`.empty? or fail('Please commit your changes before finishing the update.')

    announce 'Finishing security update'
    note 'Working directory clean.'
    prompt('Have you successfully run all tests?', 'n', /y|yes/) or fail 'Please run tests first.'

    note 'About to: push production, checkout & pull master, merge production, push master'
    prompt('Continue?', 'n', /y|yes/) or fail 'Cancelled.'

    Util.system! 'git push', :show_cmd => true
    Util.system! 'git checkout master', :show_cmd => true
    Util.system! 'git pull', :show_cmd => true
    Util.system! 'git merge production', :show_cmd => true
    Util.system! 'git push', :show_cmd => true

    announce 'Deploying all targets'
    deploy = Util.capistrano3? ? 'deploy' : 'deploy:migrations'
    invoke_cmd 'capistrano', deploy

    success 'Successfully pushed and deployed security update'
    puts
    note 'Now send an email to customer and project lead, informing them about the update.'
    note 'Do not forget to make a joblog on a security budget, if available.'
  end
end
