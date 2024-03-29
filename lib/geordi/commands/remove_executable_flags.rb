desc 'remove-executable-flags', 'Remove executable-flags from files that should not be executable'
def remove_executable_flags
  Interaction.announce 'Removing executable-flags'

  patterns = %w[
    *.rb *.html *.erb *.haml *.yml *.css *.sass *.rake *.png *.jpg
    *.gif *.pdf *.txt *.rdoc *.feature Rakefile VERSION README Capfile
  ]
  patterns.each do |pattern|
    Interaction.note pattern
    `find . -name "#{pattern}" -exec chmod -x {} ';'`
  end

  Interaction.success 'Done.'

  Hint.did_you_know [
    :clean,
  ]
end
