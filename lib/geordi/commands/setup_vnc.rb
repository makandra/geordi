class ::String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red() colorize(31) end
  def pink() colorize(35) end
  def green() colorize(32) end
end

desc 'setup_vnc', '?'
def setup_vnc
  `clear`

  instruct <<-TEXT
    This script will help you install a VNC server and a VNC viewer.

    With those you will be able to use our cucumber script without being
    disturbed by focus-stealing selenium windows. Instead, they will open
    inside a VNC session. You can still inspect everything with #{"geordi
    vnc_show".pink}.

    Please open a second shell to execute instructions.
  TEXT

  announce 'Setup VNC server'

  if installed?('vncserver')
    success 'It appears you already have a VNC server installed. Good job!'
  else
    instruct <<-TEXT
      Please run #{'sudo apt-get install vnc4server'.pink}.
    TEXT

    instruct <<-TEXT
      We will now set a password for your VNC server.

      When running our cucumber script, you will not actually need this
      password, and there is no security risk. However, if you start a vncserver
      without our cucumber script, a user with your password can connect to
      your machine.

      Please run #{'vncserver :20'.pink} and #{'enter a secure password'.red}.
    TEXT

    instruct <<-TEXT
      Now stop the server again.
      Please run #{'vncserver -kill :20'.pink}.
    TEXT
  end

  announce 'Setup VNC viewer'

  if installed?('vncviewer')
    success 'It appears you already have a VNC viewer installed. Good job!'
  else
    instruct <<-TEXT
      Please run #{'sudo apt-get install xtightvncviewer'.pink}.
    TEXT
  end

  instruct <<-TEXT, false
    All done. Our cucumber script will now automatically run Selenium features
    in VNC.
    #{"Happy cuking!".green}
  TEXT

end

private

def instruct(text, wait = true)
  text =~ /^( *)./
  level = $1 ? $1.size : 0
  text.gsub!(/^ {#{level}}/, '')
  puts text

  wait('[ENTER]') if wait
end

def installed?(app)
  `which #{app}`
  $?.success?
end
