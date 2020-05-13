require 'fileutils'
require 'open3'
require 'tempfile'

module Geordi
  class DBCleaner

    def initialize(extra_flags)
      puts 'Please enter your sudo password if asked, for db operations as system users'
      puts "We're going to run `sudo -u postgres psql` for PostgreSQL"
      puts '               and `sudo mysql`            for MariaDB (which uses PAM auth)'
      `sudo true`
      Interaction.fail 'sudo access is required for database operations as database users' if $CHILD_STATUS != 0
      @derivative_dbname = /_(test\d*|development|cucumber)$/
      base_directory = ENV['XDG_CONFIG_HOME']
      base_directory = Dir.home.to_s if base_directory.nil?
      @whitelist_directory = File.join(base_directory, '.config', 'geordi', 'whitelists')
      FileUtils.mkdir_p(@whitelist_directory) unless File.directory? @whitelist_directory
      @mysql_command = decide_mysql_command(extra_flags['mysql'])
      @postgres_command = decide_postgres_command(extra_flags['postgres'])
    end

    def edit_whitelist(dbtype)
      whitelist = whitelist_fname(dbtype)
      whitelisted_dbs = if File.exist? whitelist
        Geordi::Util.stripped_lines(File.read(whitelist))\
          .delete_if { |l| l.start_with? '#' }
      else
        []
      end
      all_dbs = list_all_dbs(dbtype)
      tmp = Tempfile.open("geordi_whitelist_#{dbtype}")
      tmp.write <<-HEREDOC
# Put each whitelisted database on a new line.
# System databases will never be deleted.
# When you whitelist foo, foo_development and foo_test\\d* are whitelisted, too.
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
      warn_manual_whitelist = false
      whitelisted_dbs.each do |db_name|
        # Remove 'keep' word from whitelist entries. This is not normally required since geordi
        # does not save 'keep' or 'drop' to the whitelist file on disk but rather saves a list
        # of all whitelisted db names and just presents the keep/drop information while editing
        # the whitelist to supply users a list of databases they can whitelist by changing the
        # prefix to 'keep'. Everything prefixed 'drop' is not considered whitelisted and thus
        # not written to the whitelist file on disk.
        #
        # However, if users manually edit their whitelist files they might use the keep/drop
        # syntax they're familiar with.
        if db_name.start_with? 'keep '
          db_name.gsub!(/keep /, '')
          db_name = db_name.split[1..-1].join(' ')
          warn_manual_whitelist = true
        end
        tmpfile_content.push(['keep', db_name]) unless db_name.empty?
      end
      if warn_manual_whitelist
        Interaction.warn <<-ERROR_MSG.gsub(/^\s*/, '')
        Your whitelist #{whitelist} seems to have been generated manually.
        In that case, make sure to use only one database name per line and omit the 'keep' prefix."

        Launching the editor.
        ERROR_MSG
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
        whitelisted_dbs = []
        whitelist_storage = File.open(whitelist, 'w')
        lines = Geordi::Util.stripped_lines(wl_edited.read)
        lines.each do |line|
          next if line.start_with?('#')
          unless line.split.length == 2
            Interaction.fail "Invalid edit to whitelist file: \`#{line}\` - Syntax is: ^[keep|drop] dbname$"
          end
          unless %w[keep drop k d].include? line.split.first
            Interaction.fail "Invalid edit to whitelist file: \`#{line}\` - must start with either drop or keep."
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
          port = Integer(extra_flags.split('=')[1].split[0])
          Interaction.fail "Port #{port} is not open" unless Geordi::Util.is_port_open? port
        end
        cmd << " #{extra_flags}"
      end
      Open3.popen3("#{cmd} -e 'QUIT'") do |_stdin, _stdout, stderr, thread|
        break if thread.value.exitstatus == 0
        # sudo mysql was not successful, switching to mysql-internal user management
        mysql_error = stderr.read.lines[0].chomp.strip.split[1]
        if %w[1045 1698].include? mysql_error # authentication failed
          cmd = 'mysql -uroot'
          cmd << " #{extra_flags}" unless extra_flags.nil?
          unless File.exist? File.join(Dir.home, '.my.cnf')
            puts "Please enter your MySQL/MariaDB password for account 'root'."
            Interaction.warn "You should create a ~/.my.cnf file instead, or you'll need to enter your MySQL root password for each db."
            Interaction.warn 'See https://makandracards.com/makandra/50813-store-mysql-passwords-for-development for more information.'
            cmd << ' -p' # need to ask for password now
          end
          Open3.popen3("#{cmd} -e 'QUIT'") do |_stdin_2, _stdout_2, _stderr_2, thread_2|
            Interaction.fail 'Could not connect to MySQL/MariaDB' unless thread_2.value.exitstatus == 0
          end
        elsif mysql_error == '2013' # connection to port or socket failed
          Interaction.fail 'MySQL/MariaDB connection failed, is this the correct port?'
        end
      end
      cmd
    end
    private :decide_mysql_command

    def decide_postgres_command(extra_flags)
      cmd = 'sudo -u postgres psql'
      unless extra_flags.nil?
        begin
          port = Integer(extra_flags.split('=')[1])
          Interaction.fail "Port #{port} is not open" unless Geordi::Util.is_port_open? port
        rescue ArgumentError
          socket = extra_flags.split('=')[1]
          Interaction.fail "Socket #{socket} does not exist" unless File.exist? socket
        end
        cmd << " #{extra_flags}"
      end
      cmd
    end
    private :decide_postgres_command

    def list_all_dbs(dbtype)
      if dbtype == 'postgres'
        list_all_postgres_dbs
      else
        list_all_mysql_dbs
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
      Interaction.announce 'Checking for MySQL databases'
      database_list = list_all_dbs('mysql')
      # confirm_deletion includes option for whitelist editing
      deletable_dbs = confirm_deletion('mysql', database_list)
      return if deletable_dbs.nil?
      deletable_dbs.each do |db|
        if @mysql_command.include? '-p'
          puts "Please enter your MySQL/MariaDB account 'root' for: DROP DATABASE #{db}"
        else
          Interaction.note "Dropping MySQL/MariaDB database #{db}"
        end
        `#{@mysql_command} -e 'DROP DATABASE \`#{db}\`;'`
      end
    end

    def clean_postgres
      Interaction.announce 'Checking for Postgres databases'
      database_list = list_all_dbs('postgres')
      deletable_dbs = confirm_deletion('postgres', database_list)
      return if deletable_dbs.nil?
      deletable_dbs.each do |db|
        Interaction.note "Dropping PostgreSQL database `#{db}`."
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
          Interaction.note "No #{dbtype} databases found that were not whitelisted"
          if Interaction.prompt('Edit the whitelist? [y]es or [n]o') == 'y'
            proceed = 'e'
          else
            return []
          end
        end
        if proceed.empty?
          Interaction.note "The following #{dbtype} databases are not whitelisted and could be deleted:"
          deletable_dbs.sort.each do |db|
            puts db
          end
          Interaction.note "Those #{dbtype} databases are not whitelisted and could be deleted."
          proceed = Interaction.prompt('Proceed? [y]es, [n]o or [e]dit whitelist')
        end
        case proceed
        when 'e'
          proceed = '' # reset user selection
          edit_whitelist dbtype
        when 'n'
          Interaction.success 'Not deleting anything'
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
      whitelist_content = if File.exist? whitelist_fname(dbtype)
        Geordi::Util.stripped_lines(File.open(whitelist_fname(dbtype), 'r').read)
      else
        []
      end
      # Allow explicit whitelisting of derivative databases like projectname_test2
      if whitelist_content.include? database_name
        true
      # whitelisting `projectname` also whitelists `projectname_test\d*`, `projectname_development`
      elsif whitelist_content.include? database_name.sub(@derivative_dbname, '')
        true
      else
        false
      end
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
