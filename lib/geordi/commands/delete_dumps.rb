desc 'delete-dumps [DIRECTORY]', 'Help deleting database dump files (*.dump)'
long_desc <<-LONGDESC
Example: `geordi delete-dumps` or `geordi delete-dumps ~/tmp/dumps`

Recursively searches for files ending in `.dump` and offers to delete them. When
no argument is given, two default directories are searched for dump files: the
current working directory and `~/dumps` (for dumps created with geordi).

Will ask for confirmation before actually deleting files.
LONGDESC

def delete_dumps(*locations)
  Interaction.announce 'Retrieving dump files'

  dump_files = []
  if locations.empty?
    locations = [ File.join(Dir.home, 'dumps'), Dir.pwd ]
  end
  locations.map! &File.method(:expand_path)

  Interaction.note "Looking in #{locations.join(', ')}"
  locations.each do |dir|
    directory = File.expand_path(dir)
    unless File.directory? File.realdirpath(directory)
      Interaction.warn "Directory #{directory} does not exist. Skipping."
      next
    end
    dump_files.concat Dir.glob("#{directory}/**/*.dump")
  end
  deletable_dumps = dump_files.flatten.uniq.sort.select &File.method(:file?)

  if deletable_dumps.empty?
    Interaction.warn 'No dump files found.'
  else
    puts deletable_dumps
    Interaction.confirm_or_cancel('Delete these files?', default: 'n')

    deletable_dumps.each &File.method(:delete)
    Interaction.success 'Done.'
  end

  Hint.did_you_know [
    :clean,
    :drop_databases,
    :dump,
  ]
end
