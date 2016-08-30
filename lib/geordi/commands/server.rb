desc 'server [PORT]', 'Start a development server'

option :port, :aliases => '-p', :default => '3000',
  :desc => 'Choose a port'

def server(port = nil)
  invoke_cmd 'bundle_install'
  require 'geordi/util'

  announce 'Booting a development server'
  port ||= options.port
  note "URL: http://#{ File.basename(Dir.pwd) }.vcap.me:#{port}"
  puts

  # -b 0.0.0.0: Allow connections from other machines, e.g. a testing iPad
  Util.system! Util.server_command, "-p #{ port }", '-b 0.0.0.0'
end

map 'devserver' => 'server'
