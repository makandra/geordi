desc '-setup-vnc', 'Setup VNC for running Selenium tests there', hide: true
def _setup_vnc
  `clear`

  Interaction.note 'This script will help you install a VNC server and a VNC viewer.'
  puts
  puts Util.strip_heredoc <<-TEXT
    With those you will be able to use our cucumber script without being
    disturbed by focus-stealing Selenium windows. Instead, they will open
    inside a VNC session.

    You can still inspect everything with:
  TEXT
  Interaction.note_cmd 'geordi vnc'
  puts
  Interaction.note 'Please open a second shell to execute instructions.'
  Interaction.prompt 'Continue ...'

  Interaction.announce 'Setup VNC server'

  vnc_server_installed = system('which vncserver > /dev/null 2>&1')
  if vnc_server_installed
    Interaction.success 'It appears you already have a VNC server installed. Good job!'
  else
    puts 'Please run:'
    Interaction.note_cmd 'sudo apt-get install tightvncserver'
    puts 'In case this package is not available, you may try vnc4server instead.'
    Interaction.prompt 'Continue ...'

    puts

    Interaction.note 'We will now set a password for your VNC server.'
    puts Util.strip_heredoc <<-TEXT
      When running our cucumber script, this password will be used while also
      restricting access to the local machine. However, if you start a vncserver
      without our cucumber script, keep in mind that a user with this password
      can connect to your machine.

    TEXT
    puts 'Please run:'
    Interaction.note_cmd 'vncpasswd'
    Interaction.warn 'Enter a secure password!'
    Interaction.prompt 'Continue ...'
  end

  Interaction.announce 'Setup VNC viewer'

  vnc_viewer_installed = system('which vncviewer > /dev/null 2>&1')
  if vnc_viewer_installed
    Interaction.success 'It appears you already have a VNC viewer installed. Good job!'
  else
    puts 'Please run:'
    Interaction.note_cmd 'sudo apt-get install xtightvncviewer'
    Interaction.prompt 'Continue ...'
  end

  puts
  puts Util.strip_heredoc <<-TEXT
    All done. Our cucumber script will now automatically run Selenium features
    in VNC.
  TEXT

  Interaction.success 'Happy cuking!'
end
