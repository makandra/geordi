desc 'vnc', 'Show the hidden VNC window'
long_desc <<-LONGDESC
Example: `geordi vnc` or `geordi vnc --setup`

Launch a VNC session to the hidden screen where `geordi cucumber` runs Selenium
tests.
LONGDESC

option :setup, type: :boolean, desc: 'Guide through the setup of VNC'

def vnc
  if options.setup
    invoke_geordi :_setup_vnc
  else
    require 'geordi/cucumber'
    Geordi::Cucumber.new.launch_vnc_viewer
  end
end
