desc 'vnc_show', 'Show the hidden VNC window'
def vnc_show
  require File.expand_path('../../cucumber', __FILE__)

  Geordi::Cucumber.new.launch_vnc_viewer
end
