desc 'delete_dumps [DIRECTORY]', 'delete database dump files (*.dump)'
long_desc <<-LONGDESC
Delete database dump files (files ending with *.dump) recursively.

If DIRECTORY is not supplied, the script will look for database dumps
in ~/dumps and the current project's directory.

If DIRECTORY is supplied, the script will only look in that directory.
LONGDESC

def delete_dumps(dump_directory = nil)
  deletable_dumps = []
  if dump_directory.nil?
    announce 'Cleaning default directories'
    dump_directories = [
      File.join(Dir.home, 'dumps'),
      Dir.pwd
    ]
  else
    announce "Cleaning #{dump_directory}"
    dump_directories = [dump_directory]
  end
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
  deletable_dumps.uniq!
  note 'The following dumps can be deleted:'
  puts
  puts deletable_dumps
  prompt 'Delete those dumps', 'n', /y|yes/ or fail 'Cancelled.'
  deletable_dumps.each do |dump|
    File.delete dump unless File.directory? dump
  end
end
