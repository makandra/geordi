require 'rubygems'
require 'highline'


class DumpLoader

  def initialize(argv)
    @argv = argv
    @verbose = !!@argv.delete('-v')
  end

  def dumps_dir
    require 'etc'
    user_dir = Etc.getpwuid.dir
    File.join(user_dir, 'dumps')
  end

  def db_console_command
    if File.exists?("script/dbconsole")
      "script/dbconsole -p"
    else
      "rails dbconsole -p"
    end
  end

  def source_dump(dump)
    require 'open3'
    output_buffer = StringIO.new
    Open3.popen3(db_console_command) do |stdin, stdout, stderr|
      stdin.puts("source #{dump};")
      stdin.close
      output_buffer.write stdout.read
      output_buffer.write stderr.read
    end
    output_and_errors = output_buffer.string.split("\n")
    output = output_and_errors.reject{ |line| line =~ /^ERROR / }
    errors = output_and_errors.select{ |line| line =~ /^ERROR / }

    [output, errors]
  end

  def choose_dump_file
    highline = HighLine.new

    available_dumps = Dir.glob("#{dumps_dir}/*.dump").sort
    selected_dump = highline.choose(*available_dumps) do |menu|
      menu.hidden('') { exit }
    end
  end

  def get_dump_file
    if @argv[0] && File.exists?(@argv[0])
      @argv[0]
    else
      choose_dump_file
    end
  end


  def puts_info(msg = "")
    puts msg if @verbose
  end

  def execute
    dump_to_load = get_dump_file

    puts_info
    puts_info "sourcing #{dump_to_load} into db ..."

    output, errors = source_dump(dump_to_load)

    puts_info
    puts_info output.join("\n")

    if errors.empty?
      puts_info "sourcing completed successfully."
      true
    else
      $stderr.puts "some errors occured while loading the dump #{File.basename(dump_to_load)}:"
      $stderr.puts errors.join("\n");
      false
    end
  end

  def execute!
    if execute
      exit(0)
    else
      exit(1)
    end
  end

end

