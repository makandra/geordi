desc 'clean', 'Remove unneeded files from the current directory'
def clean
  announce 'Removing tempfiles'
  %w[webrat-* capybara-* tmp/webrat-* tmp/capybara-* tmp/rtex/* log/*.log].each do |pattern|
    note pattern
    puts `rm -vfR #{pattern}`
  end

  announce 'Finding recursively and removing backup files'
  %w[*~].each do |pattern|
    note pattern
    `find . -name #{pattern} -exec rm {} ';'`
  end
end
