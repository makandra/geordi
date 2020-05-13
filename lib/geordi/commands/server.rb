desc 'server [PORT]', 'Start a development server'

option :port, aliases: '-p', default: '3000',
  desc: 'Choose a port'
option :public, aliases: '-P', type: :boolean,
  desc: 'Make the server accessible in the local network'

def server(port = nil)
  invoke_cmd 'bundle_install'
  invoke_cmd 'yarn_install'
  require 'geordi/util'

  Interaction.announce 'Booting a development server'
  port ||= options.port
  Interaction.note "URL: http://#{File.basename(Dir.pwd)}.vcap.me:#{port}"
  puts

  command = Util.server_command
  command << ' -b 0.0.0.0' if options.public
  command << ' -p ' << port
  Util.system! command
end

map 'devserver' => 'server'
