desc 'yarn', 'Runs yarn install', :hide => true

def yarn
  if File.exists?('package.json')
    Util.system! 'yarn'
  end
end
