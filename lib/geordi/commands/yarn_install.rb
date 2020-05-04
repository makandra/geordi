desc 'yarn-install', 'Runs yarn install if required', hide: true

def yarn_install
  if File.exist?('package.json') && !system('yarn check --integrity > /dev/null 2>&1')
    announce 'Yarn install'
    Util.system! 'yarn install'
  end
end
