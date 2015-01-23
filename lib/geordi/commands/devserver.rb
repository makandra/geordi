desc 'devserver', 'Start a development server'

option :port, :aliases => '-p', :default => '3000'

def devserver
  invoke_cmd 'bundle_install'
  require 'geordi/util'

  announce 'Booting a development server'
  note "URL: http://#{File.basename(Dir.pwd)}.vcap.me:#{options.port}"
  puts

  Util.system! Util.server_command + " -p #{options.port}"
end
