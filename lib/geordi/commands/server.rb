desc 'server [PORT]', 'Start a development server'

option :port, aliases: '-p', default: '3000',
  desc: 'Choose a port'
option :public, aliases: '-P', type: :boolean,
  desc: 'Make the server accessible from the local network'

def server(port = nil)
  Hint.did_you_know [
    [:server, :public],
  ]

  invoke_geordi 'bundle_install'
  invoke_geordi 'yarn_install'
  require 'geordi/util'

  Interaction.announce 'Booting a development server'
  port ||= options.port
  Interaction.note "URL: http://#{File.basename(Dir.pwd)}.daho.im:#{port}"
  puts

  command = Util.server_command
  command << ' -b 0.0.0.0' if options.public
  command << ' -p ' << port
  Util.run!(command)
end

map 'devserver' => 'server'
