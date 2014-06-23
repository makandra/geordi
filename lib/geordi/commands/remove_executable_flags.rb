desc 'remove_executable_flags', 'Remove executable-flags from files that should not be executable'
def remove_executable_flags
  announce 'Removing executable-flags'

  patterns = %w[
    *.rb *.html *.erb *.haml *.yml *.css *.sass *.rake *.png *.jpg
    *.gif *.pdf *.txt *.rdoc *.feature Rakefile VERSION README Capfile
  ]
  for pattern in patterns
    note pattern
    `find . -name "#{pattern}" -exec chmod -x {} ';'`
  end
  puts 'Done.'
end
