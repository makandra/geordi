desc 'cleanup_directory', 'Remove unneeded files'
def cleanup_directory

  announce 'Removing tempfiles'
  for pattern in %w[ webrat-* capybara-* tmp/webrat-* tmp/capybara-* tmp/rtex/* log/*.log ]
    note pattern
    puts `rm -vfR #{pattern}`
  end

  announce 'Finding recursively and removing backup files'
  for pattern in %w[ *~ ]
    note pattern
    `find . -name #{pattern} -exec rm {} ';'`
  end

end
