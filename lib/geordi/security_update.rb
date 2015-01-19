desc 'security-update', 'Support for performing security updates'
long_desc <<-LONGDESC
Without

LONGDESC

def security_update(step='prepare')
  case step
  when 'prepare'
    announce 'Preparing for security update'
    note 'Agenda: pull master and production branches, checkout production'
    wait 'Do you agree?'

    Util.system! 'git checkout master', :show_cmd => true
    Util.system! 'git pull', :show_cmd => true
    Util.system! 'git checkout production', :show_cmd => true
    Util.system! 'git pull', :show_cmd => true

    success 'Successfully prepared for security update'

    note 'Please apply the security update now.'
    note 'When you are done, run `geordi security-update finish`.'


  when 'finish'
    announce 'Finishing security update'

  end
end
