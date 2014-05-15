desc 'bundle_install', 'Run bundle install if required', :hide => true
def bundle_install
  if File.exists?('Gemfile') and !system('bundle check &>/dev/null')
    announce 'Bundling'
    system! 'bundle install'
  end
end
