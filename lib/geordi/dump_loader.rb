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

  def development_database_config
    require 'yaml'

    @config ||= YAML::load(ERB.new(File.read('config/database.yml')).result)
    @config['development']
  end
  alias_method :config, :development_database_config
  
  def mysql_command
    ENV['MYSQL_PWD'] = config['password']
    command = 'mysql --silent'
    command << ' -u' << config['username']
    command << ' --default-character-set=utf8'
    command << ' ' << config['database']
    command << ' < ' << dump_file
  end
  alias_method :mysql2_command, :mysql_command
  
  def postgresql_command
    ENV['PGPASSWORD'] = config['password']
    command = 'pg_restore --no-owner --clean'
    command << ' --username=' << config['username']
    command << ' --host=' << config['host']
    command << ' --dbname=' << config['database']
    command << ' ' << dump_file
  end

  def source_dump!
    source_command = send("#{config['adapter']}_command")
    `#{source_command}`
  end

  def choose_dump_file
    highline = HighLine.new

    available_dumps = Dir.glob("#{dumps_dir}/*.dump").sort
    selected_dump = highline.choose(*available_dumps) do |menu|
      menu.hidden('') { exit }
    end
  end

  def dump_file
    @dump_file ||= if @argv[0] && File.exists?(@argv[0])
      @argv[0]
    else
      choose_dump_file
    end
  end

  def execute
    puts "Sourcing #{dump_file} into #{config['database']} db ..." if @verbose

    source_dump!

    if $?.success?
      puts 'Successfully sourced the dump.' if @verbose
    else
      $stderr.puts "An error occured while loading the dump #{File.basename(dump_file)}."
    end
    
    $?.success?
  end

  def execute!
    execute or exit(1)
  end

end

