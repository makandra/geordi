desc 'vnc', 'Show the hidden VNC window'
long_desc <<-LONGDESC
Example: `geordi vnc` or `geordi vnc --setup`

Launch a VNC session to the hidden screen where `geordi cucumber` runs Selenium
tests.

When called with `--setup`, will guide through the setup of VNC.
LONGDESC

option :setup, :type => :boolean

def vnc
  if options.setup
    invoke_cmd :_setup_vnc
  else
    require 'geordi/cucumber'
    Geordi::Cucumber.new.launch_vnc_viewer
  end
end
