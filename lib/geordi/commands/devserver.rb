desc 'devserver', 'Start a development server'

option :port, :aliases => '-p', :default => '3000'

def devserver
  invoke 'bundle_install'

  announce 'Booting a development server'
  note 'Port: ' + options.port

  command = if File.exists?('script/server')
    'script/server' # Rails 2
  else
    'bundle exec rails server' # Rails 3+
  end

  command << " -p #{options.port}"
  system command
end
