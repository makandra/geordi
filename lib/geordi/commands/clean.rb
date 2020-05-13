desc 'clean', 'Remove unneeded files from the current directory'
def clean

  Interaction.announce 'Removing tempfiles'
  for pattern in %w[ webrat-* capybara-* tmp/webrat-* tmp/capybara-* tmp/rtex/* log/*.log ]
    Interaction.note pattern
    puts `rm -vfR #{pattern}`
  end

  Interaction.announce 'Finding recursively and removing backup files'
  %w[*~].each do |pattern|
    Interaction.note pattern
    `find . -name #{pattern} -exec rm {} ';'`
  end
end
