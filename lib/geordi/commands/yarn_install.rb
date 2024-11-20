desc 'yarn-install', 'Runs yarn install if required', hide: true

def yarn_install
  if File.exist?('yarn.lock') && !system('yarn check --integrity > /dev/null 2>&1')
    Interaction.announce 'Yarn install'
    Util.run!('yarn install')
  end
end
