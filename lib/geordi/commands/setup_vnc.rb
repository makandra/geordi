desc 'setup-vnc', 'Setup VNC for running Selenium tests there'
def setup_vnc
  `clear`

  note 'This script will help you install a VNC server and a VNC viewer.'
  puts
  puts strip_heredoc <<-TEXT
    With those you will be able to use our cucumber script without being
    disturbed by focus-stealing Selenium windows. Instead, they will open
    inside a VNC session.

    You can still inspect everything with:
  TEXT
  note_cmd 'geordi vnc-show'
  puts
  note 'Please open a second shell to execute instructions.'
  prompt 'Continue ...'

  announce 'Setup VNC server'

  vnc_server_installed = system('which vncserver > /dev/null 2>&1')
  if vnc_server_installed
    success 'It appears you already have a VNC server installed. Good job!'
  else
    puts 'Please run:'
    note_cmd 'sudo apt-get install vnc4server'
    prompt 'Continue ...'

    puts
    note 'We will now set a password for your VNC server.'
    puts strip_heredoc <<-TEXT
      When running our cucumber script, you will not actually need this
      password, and there is no security risk. However, if you start a vncserver
      without our cucumber script, a user with your password can connect to
      your machine.

    TEXT
    puts 'Please run:'
    note_cmd 'vncserver :20'
    warn 'Enter a secure password!'
    prompt 'Continue ...'

    puts 'Now stop the server again. Please run:'
    note_cmd 'vncserver -kill :20'
    prompt 'Continue ...'
  end

  announce 'Setup VNC viewer'

  vnc_viewer_installed = system('which vncviewer > /dev/null 2>&1')
  if vnc_viewer_installed
    success 'It appears you already have a VNC viewer installed. Good job!'
  else
    puts 'Please run:'
    note_cmd 'sudo apt-get install xtightvncviewer'
    prompt 'Continue ...'
  end

  puts
  puts strip_heredoc <<-TEXT
    All done. Our cucumber script will now automatically run Selenium features
    in VNC.
  TEXT

  success 'Happy cuking!'
end
