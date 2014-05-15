desc 'vnc_show', 'Show the hidden VNC window'
def vnc_show
  require 'geordi/cucumber'

  Geordi::Cucumber.new.launch_vnc_viewer
end
