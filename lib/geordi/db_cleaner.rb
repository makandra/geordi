require 'fileutils'
require 'open3'
require 'tempfile'

module Geordi
  class DBCleaner
    include Geordi::Interaction

    def initialize(extra_flags)
      puts 'Please enter your sudo password if asked, for db operations as system users'
      puts "We're going to run `sudo -u postgres psql` for PostgreSQL"
      puts '               and `sudo mysql`            for MariaDB (which uses PAM auth)'
      `sudo true`
      fail 'sudo access is required for database operations as database users' if $? != 0
      @derivative_dbname = /_(test\d?|development|cucumber)$/
      base_directory = ENV['XDG_CONFIG_HOME']
      base_directory = "#{Dir.home}" if base_directory.nil?
      @whitelist_directory = File.join(base_directory, '.config', 'geordi', 'whitelists')
      FileUtils.mkdir_p(@whitelist_directory) unless File.directory? @whitelist_directory
      @mysql_command = decide_mysql_command(extra_flags['mysql'])
      @postgres_command = decide_postgres_command(extra_flags['postgres'])
    end

    def edit_whitelist(dbtype)
      whitelist = whitelist_fname(dbtype)
      if File.exist? whitelist
        whitelisted_dbs = Geordi::Util.stripped_lines(File.read(whitelist))\
          .delete_if { |l| l.start_with? '#' }
      else
        whitelisted_dbs = Array.new
      end
      all_dbs = list_all_dbs(dbtype)
      tmp = Tempfile.open("geordi_whitelist_#{dbtype}")
      tmp.write <<-HEREDOC
# Put each whitelisted database on a new line.
# System databases will never be deleted.
# When you whitelist foo, foo_development and foo_test\\d? are whitelisted, too.
# This works even if foo does not exist. Also, you will only see foo in this list.
#
# Syntax: keep foo
#         drop bar
HEREDOC
      tmpfile_content = Array.new
      all_dbs.each do |db|
        next if is_whitelisted?(dbtype, db)
        next if is_protected?(dbtype, db)
        db.sub!(@derivative_dbname, '')
        tmpfile_content.push(['drop', db])
      end
      whitelisted_dbs.each do |db|
        tmpfile_content.push(['keep', db])
      end
      tmpfile_content.sort_by! { |k| k[1] }
      tmpfile_content.uniq!
      tmpfile_content.each do |line|
        tmp.write("#{line[0]} #{line[1]}\n")
      end
      tmp.close
      texteditor = Geordi::Util.decide_texteditor
      system("#{texteditor} #{tmp.path}")
      File.open(tmp.path, 'r') do |wl_edited|
        whitelisted_dbs = Array.new
        whitelist_storage = File.open(whitelist, 'w')
        lines = Geordi::Util.stripped_lines(wl_edited.read)
        lines.each do |line|
          next if line.start_with?('#')
          unless line.split.length == 2
            fail "Invalid edit to whitelist file: \`#{line}\` - Syntax is: ^[keep|drop] dbname$"
          end
          unless %w[keep drop k d].include? line.split.first
            fail "Invalid edit to whitelist file: \`#{line}\` - must start with either drop or keep."
          end
          db_status, db_name = line.split
          if db_status == 'keep'
            whitelisted_dbs.push db_name
            whitelist_storage.write(db_name << "\n")
          end
        end
        whitelist_storage.close
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
            puts "Please enter your MySQL/MariaDB password for account 'root'."
            warn "You should create a ~/.my.cnf file instead, or you'll need to enter your MySQL root password for each db."
            warn "See https://makandracards.com/makandra/50813-store-mysql-passwords-for-development for more information."
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
      if @mysql_command.include? '-p'
        puts "Please enter your MySQL/MariaDB account 'root' for: list all databases"
      end
      `#{@mysql_command} -B -N -e 'show databases'`.split
    end

    def clean_mysql
      announce 'Checking for MySQL databases'
      database_list = list_all_dbs('mysql')
      # confirm_deletion includes option for whitelist editing
      deletable_dbs = confirm_deletion('mysql', database_list)
      return if deletable_dbs.nil?
      deletable_dbs.each do |db|
        if @mysql_command.include? '-p'
          puts "Please enter your MySQL/MariaDB account 'root' for: DROP DATABASE #{db}"
        else
          note "Dropping MySQL/MariaDB database #{db}"
        end
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

    def is_protected?(dbtype, database_name)
      protected = {
        'mysql'    => %w[mysql information_schema performance_schema sys],
        'postgres' => ['postgres'],
      }
      protected[dbtype].include? database_name
    end

    def is_whitelisted?(dbtype, database_name)
      if File.exist? whitelist_fname(dbtype)
        whitelist_content = Geordi::Util.stripped_lines(File.open(whitelist_fname(dbtype), 'r').read)
      else
        whitelist_content = Array.new
      end
      whitelist_content.include? database_name.sub(@derivative_dbname, '')
    end

    def filter_whitelisted(dbtype, database_list)
      # n.b. `delete` means 'delete from list of dbs that should be deleted in this context
      # i.e. `delete` means 'keep this database'
      deletable_dbs = database_list.dup
      deletable_dbs.delete_if { |db| is_whitelisted?(dbtype, db) if File.exist? whitelist_fname(dbtype) }
      deletable_dbs.delete_if { |db| is_protected?(dbtype, db) }
      deletable_dbs.delete_if { |db| db.start_with? '#' }
    end
    private :filter_whitelisted
  end
end
