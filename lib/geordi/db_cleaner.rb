require 'fileutils'
require 'socket'
require 'open3'

module Geordi
  class DBCleaner
    include Geordi::Interaction

    def initialize(extra_flags)
      base_directory = ENV['XDG_CONFIG_HOME']
      base_directory = "#{Dir.home}" if base_directory.nil?
      @whitelist_directory = File.join(base_directory, '.config', 'geordi', 'whitelists')
      FileUtils.mkdir_p(@whitelist_directory) unless File.directory? @whitelist_directory
      @mysql_command = decide_mysql_command(extra_flags['mysql'])
      @postgres_command = decide_postgres_command(extra_flags['postgres'])
    end

    def edit_whitelist(dbtype)
      whitelist = whitelist_fname(dbtype)
      texteditor = choose_texteditor
      system("#{texteditor} #{whitelist}")
    end

    def create_new_whitelist(dbtype)
      whitelist = whitelist_fname(dbtype)
      return if File.exist? whitelist
      File.open(whitelist, 'w') do |wl|
        wl.write('# System databases are always whitelisted')
      end
    end

    def decide_mysql_command(extra_flags)
      cmd = 'sudo mysql'
      unless extra_flags.nil?
        if extra_flags.include? 'port'
          port = Integer(extra_flags.split('=')[1].split()[0])
          fail "Port #{port} is not open" unless Geordi::Util.is_port_open? port
        end
        cmd << " #{extra_flags}"
      end
      Open3.popen3("#{cmd} -e 'QUIT'") do |stdin, stdout, stderr, thread|
        break if thread.value.exitstatus == 0
        # sudo mysql was not successful, switching to mysql-internal user management
        mysql_error = stderr.read.lines[0].chomp.strip.split[1]
        if %w[1045 1698].include? mysql_error  # authentication failed
          cmd = 'mysql -uroot'
          cmd << " #{extra_flags}" unless extra_flags.nil?
          unless File.exist? File.join(Dir.home, '.my.cnf')
            warn "You should create a ~/.my.cnf file first, or you'll need to enter your MySQL root password for each db.\n
                  See https://makandracards.com/makandra/50813-store-mysql-passwords-for-development for more information."
            cmd << ' -p'  # need to ask for password now
          end
          Open3.popen3("#{cmd} -e 'QUIT'") do |stdin2, stdout2, stderr2, thread2|
            fail 'Could not connect to MySQL/MariaDB' unless thread2.value.exitstatus == 0
          end
        elsif mysql_error == '2013'  # connection to port or socket failed
          fail 'MySQL/MariaDB connection failed, is this the correct port?'
        end
      end
      return cmd
    end
    private :decide_mysql_command

    def decide_postgres_command(extra_flags)
      cmd = 'sudo -u postgres psql'
      unless extra_flags.nil?
        begin
          port = Integer(extra_flags.split('=')[1])
          fail "Port #{port} is not open" unless Geordi::Util.is_port_open? port
        rescue ArgumentError
          socket = extra_flags.split('=')[1]
          fail "Socket #{socket} does not exist" unless File.exist? socket
        end
        cmd << " #{extra_flags}"
      end
      return cmd
    end
    private :decide_postgres_command

    def list_all_dbs(dbtype)
      if dbtype == 'postgres'
        return list_all_postgres_dbs
      else
        return list_all_mysql_dbs
      end
    end

    def list_all_postgres_dbs
      `#{@postgres_command} -t -A -c 'SELECT DATNAME FROM pg_database WHERE datistemplate = false'`.split
    end

    def list_all_mysql_dbs
      `#{@mysql_command} -B -N -e 'show databases'`.split
    end

    def clean_mysql
      announce 'Checking for MySQL databases'
      database_list = list_all_dbs('mysql')
      # confirm_deletion includes option for whitelist editing
      deletable_dbs = confirm_deletion('mysql', database_list)
      return if deletable_dbs.nil?
      deletable_dbs.each do |db|
        note "Dropping MySQL/MariaDB database #{db}"
        `#{@mysql_command} -e 'DROP DATABASE \`#{db}\`;'`
      end
    end

    def clean_postgres
      announce 'Checking for Postgres databases'
      database_list = list_all_dbs('postgres')
      deletable_dbs = confirm_deletion('postgres', database_list)
      return if deletable_dbs.nil?
      deletable_dbs.each do |db|
        note "Dropping PostgreSQL database `#{db}`."
        `#{@postgres_command} -c 'DROP DATABASE "#{db}";'`
      end
    end

    def whitelist_fname(dbtype)
      File.join(@whitelist_directory, dbtype) << '.txt'
    end

    def confirm_deletion(dbtype, database_list)
      proceed = ''
      until %w[y n].include? proceed
        deletable_dbs = filter_whitelisted(dbtype, database_list)
        if deletable_dbs.empty?
          note "No #{dbtype} databases found that were not whitelisted"
          if prompt('Edit the whitelist? [y]es or [n]o') == 'y'
            proceed = 'e'
          else
            return []
          end
        end
        if proceed.empty?
          note "The following #{dbtype} databases are not whitelisted and could be deleted:"
          deletable_dbs.sort.each do |db|
            puts db
          end
          note "Those #{dbtype} databases are not whitelisted and could be deleted."
          proceed = prompt('Proceed? [y]es, [n]o or [e]dit whitelist')
        end
        case proceed
        when 'e'
          proceed = ''  # reset user selection
          edit_whitelist dbtype
        when 'n'
          success 'Not deleting anything'
          return []
        when 'y'
          return deletable_dbs
        end
      end
    end
    private :confirm_deletion

    def create_whitelist(dbtype)
      whitelist = File.open(whitelist_fname(dbtype), 'w')
      if dbtype == 'mysql'
        whitelist.write("# Always whitelisted:\n# information_schema\n# performance_schema\n# mysql\n# sys\n")
      elsif dbtype == 'postgres'
        whitelist.write("# Always whitelisted: \n # postgres\n")
      end
      whitelist.write("# When you whitelist `foo`, `foo_development` and `foo_test\d?` will be considered whitelisted, too.")
      whitelist.close
    end

    def filter_whitelisted(dbtype, database_list)
      create_whitelist(dbtype) unless File.exist? whitelist_fname(dbtype)
      protected = {
        'mysql'    => %w[mysql information_schema performance_schema sys],
        'postgres' => ['postgres'],
      }
      whitelist_content = File.open(whitelist_fname(dbtype), 'r').read.lines.map(&:chomp).map(&:strip)
      # n.b. `delete` means 'delete from list of dbs that should be deleted in this context
      # i.e. `delete` means 'keep this database'
      deletable_dbs = database_list.dup
      deletable_dbs.delete_if { |db| whitelist_content.include? db.sub(/_(test\d?|development)$/, '') }
      deletable_dbs.delete_if { |db| protected[dbtype].include? db }
      deletable_dbs.delete_if { |db| db.start_with? '#' }
    end
    private :filter_whitelisted
  end
end

def choose_texteditor
  %w[$VISUAL $EDITOR /usr/bin/editor vi].each do |texteditor|
    return texteditor if cmd_exists? texteditor
  end
end

def cmd_exists? cmd
  system("which #{cmd} > /dev/null")
  return $?.exitstatus.zero?
end

def is_port_open?(port)
  begin
    socket = TCPSocket.new('127.0.0.1', port)
    socket.close
    return true
  rescue Errno::ECONNREFUSED
    return false
  end
end
