desc 'delete_dumps [DIRECTORY]', 'Delete database dump files (*.dump)'
long_desc <<-LONGDESC
Example: `geordi delete_dumps` or `geordi delete_dumps ~/tmp/dumps`

Recursively search for files ending in `*.dump` and offer to delete those. When
no argument is given, two default directories are searched for dump files: the
current working directory and `~/dumps` (for dumps created with geordi).

Geordi will ask for confirmation before actually deleting files.

LONGDESC

def delete_dumps(dump_directory = nil)
  deletable_dumps = []
  if dump_directory.nil?
    dump_directories = [
      File.join(Dir.home, 'dumps'),
      Dir.pwd
    ]
  else
    dump_directories = [dump_directory]
  end
  announce 'Looking for *.dump in ' << dump_directories.join(',')
  dump_directories.each do |d|
    d2 = File.expand_path(d)
    unless File.directory? File.realdirpath(d2)
      warn "Directory #{d2} does not exist"
      next
    end
    deletable_dumps.concat(Dir.glob("#{d2}/**/*.dump"))
  end
  if deletable_dumps.empty?
    success 'No dumps to delete' if deletable_dumps.empty?
    exit 0
  end
  deletable_dumps.uniq!.sort!
  note 'The following dumps can be deleted:'
  puts
  puts deletable_dumps
  prompt 'Delete those dumps', 'n', /y|yes/ or fail 'Cancelled.'
  deletable_dumps.each do |dump|
    File.delete dump unless File.directory? dump
  end
end
