require 'fileutils'
require 'open3'
require 'tempfile'

module Geordi

  DatabaseError = Class.new(StandardError)

  class DBCleaner

    def initialize(extra_flags, sudo: false)
      @sudo = sudo

      if @sudo
        Interaction.note 'Please enter your sudo password when asked.'
        puts "We're going to run `sudo -u postgres psql` for PostgreSQL"
        puts '               and `sudo mysql`            for MariaDB (which uses PAM auth)'
        `sudo true`
        Interaction.fail 'sudo access is required for database operations as database users' if $? != 0
      end

      @derivative_dbname = /_(test\d*|development|cucumber)$/
      @base_directory = ENV['XDG_CONFIG_HOME']
      @base_directory ||= Dir.home.to_s
      @allowlist_directory = File.join(@base_directory, '.config', 'geordi', 'allowlists')
      FileUtils.mkdir_p(@allowlist_directory) unless File.directory? @allowlist_directory
      if File.directory?(legacy_allowlist_directory)
        move_allowlist_files
      end
      @mysql_command = decide_mysql_command(extra_flags['mysql'])
      @postgres_command = decide_postgres_command(extra_flags['postgres'])
      @texteditor = Geordi::Util.get_texteditor
    end

    def edit_allowlist(dbtype)
      allowlist = allowlist_fname(dbtype)
      allowlisted_dbs = if File.exist? allowlist
        Geordi::Util.stripped_lines(File.read(allowlist))\
          .delete_if { |l| l.start_with? '#' }
      else
        []
      end
      all_dbs = list_all_dbs(dbtype)
      tmp = Tempfile.open("geordi_allowlist_#{dbtype}")
      tmp.write <<~HEREDOC
        # Put each allowlisted database on a new line.
        # System databases will never be deleted.
        # When you allowlist foo, foo_development and foo_test\\d* are allowlisted, too.
        # This works even if foo does not exist. Also, you will only see foo in this list.
        #
        # Syntax: keep foo
        #         drop bar
      HEREDOC
      tmpfile_content = Array.new
      all_dbs.each do |db|
        next if is_allowlisted?(dbtype, db)
        next if is_protected?(dbtype, db)
        db.sub!(@derivative_dbname, '')
        tmpfile_content.push(['drop', db])
      end
      warn_manual_allowlist = false
      allowlisted_dbs.each do |db_name|
        # Remove 'keep' word from allowlist entries. This is not normally required since geordi
        # does not save 'keep' or 'drop' to the allowlist file on disk but rather saves a list
        # of all allowlisted db names and just presents the keep/drop information while editing
        # the allowlist to supply users a list of databases they can allowlist by changing the
        # prefix to 'keep'. Everything prefixed 'drop' is not considered allowlisted and thus
        # not written to the allowlist file on disk.
        #
        # However, if users manually edit their allowlist files they might use the keep/drop
        # syntax they're familiar with.
        if db_name.start_with? 'keep '
          db_name.gsub!(/keep /, '')
          db_name = db_name.split[1..-1].join(' ')
          warn_manual_allowlist = true
        end
        tmpfile_content.push(['keep', db_name]) unless db_name.empty?
      end
      if warn_manual_allowlist
        Interaction.warn <<~ERROR_MSG
          Your allowlist #{allowlist} seems to have been generated manually.
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
      system("#{@texteditor} #{tmp.path}")
      File.open(tmp.path, 'r') do |wl_edited|
        allowlisted_dbs = []
        allowlist_storage = File.open(allowlist, 'w')
        lines = Geordi::Util.stripped_lines(wl_edited.read)
        lines.each do |line|
          next if line.start_with?('#')
          unless line.split.length == 2
            Interaction.fail "Invalid edit to allowlist file: \`#{line}\` - Syntax is: ^[keep|drop] dbname$"
          end
          unless %w[keep drop k d].include? line.split.first
            Interaction.fail "Invalid edit to allowlist file: \`#{line}\` - must start with either drop or keep."
          end
          db_status, db_name = line.split
          if db_status == 'keep'
            allowlisted_dbs.push db_name
            allowlist_storage.write(db_name << "\n")
          end
        end
        allowlist_storage.close
      end
    end

    def decide_mysql_command(extra_flags)
      cmd = @sudo ? 'sudo mysql' : 'mysql'
      unless extra_flags.nil?
        if extra_flags.include? 'port'
          port = Integer(extra_flags.split('=')[1].split[0])
          Interaction.fail "Port #{port} is not open" unless Geordi::Util.is_port_open? port
        end
        cmd << " #{extra_flags}"
      end

      if @sudo
        Open3.popen3("#{cmd} -e 'QUIT'") do |_stdin, _stdout, stderr, thread|
          break if thread.value.exitstatus == 0
          # sudo mysql was not successful, switching to mysql-internal user management
          mysql_error = stderr.read.lines[0].chomp.strip.split[1]
          if %w[1045 1698].include? mysql_error # authentication failed
            cmd = 'mysql -uroot'
            cmd << " #{extra_flags}" unless extra_flags.nil?
            unless File.exist? File.join(Dir.home, '.my.cnf')
              Interaction.note "Please enter your MySQL/MariaDB password for account 'root'."
              Interaction.warn "You should create a ~/.my.cnf file instead, or you'll need to enter your MySQL root password for each db."
              Interaction.note 'See https://makandracards.com/makandra/50813-store-mysql-passwords-for-development for more information.'
              cmd << ' -p' # need to ask for password now
            end
            Open3.popen3("#{cmd} -e 'QUIT'") do |_stdin_2, _stdout_2, _stderr_2, thread_2|
              Interaction.fail 'Could not connect to MySQL/MariaDB' unless thread_2.value.exitstatus == 0
            end
          elsif mysql_error == '2013' # connection to port or socket failed
            Interaction.fail 'MySQL/MariaDB connection failed, is this the correct port?'
          end
        end
      end
      cmd
    end
    private :decide_mysql_command

    def decide_postgres_command(extra_flags)
      cmd = @sudo ? 'sudo -u postgres psql' : 'psql'
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
    rescue DatabaseError
      Interaction.fail 'Connection to database could not be established. Try running again with --sudo.'
    end

    def list_all_postgres_dbs
      output, _error, status = Open3.capture3("#{@postgres_command} -t -A -c 'SELECT DATNAME FROM pg_database WHERE datistemplate = false'")

      raise DatabaseError unless status.success?

      output.split
    end

    def list_all_mysql_dbs
      if @mysql_command.include? '-p'
        Interaction.note "Please enter your MySQL/MariaDB account 'root' for: list all databases"
      end
      output, _error, status = Open3.capture3("#{@mysql_command} -B -N -e 'show databases'")

      raise DatabaseError unless status.success?

      output.split
    end

    def clean_mysql
      Interaction.announce 'Checking for MySQL databases'
      database_list = list_all_dbs('mysql')
      # confirm_deletion includes option for allowlist editing
      deletable_dbs = confirm_deletion('mysql', database_list)
      return if deletable_dbs.nil?
      deletable_dbs.each do |db|
        if @mysql_command.include? '-p'
          Interaction.note "Please enter your MySQL/MariaDB account 'root' for: DROP DATABASE #{db}"
        else
          puts "Dropping MySQL/MariaDB database #{db}"
        end
        `#{@mysql_command} -e 'DROP DATABASE \`#{db}\`;'`
      end
    end

    def clean_postgres
      Interaction.announce 'Checking for PostgreSQL databases'
      database_list = list_all_dbs('postgres')
      deletable_dbs = confirm_deletion('postgres', database_list)
      return if deletable_dbs.nil?
      deletable_dbs.each do |db|
        Interaction.note "Dropping PostgreSQL database `#{db}`."
        `#{@postgres_command} -c 'DROP DATABASE "#{db}";'`
      end
    end

    def allowlist_fname(dbtype)
      File.join(@allowlist_directory, dbtype) << '.txt'
    end

    def confirm_deletion(dbtype, database_list)
      proceed = ''
      until %w[y n].include? proceed
        deletable_dbs = filter_allowlisted(dbtype, database_list)
        if deletable_dbs.empty?
          Interaction.note "No #{dbtype} databases found that were not allowlisted."
          if Interaction.prompt('Edit the allowlist? [y]es or [n]o') == 'y'
            proceed = 'e'
          else
            return []
          end
        end
        if proceed.empty?
          Interaction.note "The following #{dbtype} databases are not allowlisted and can be deleted:"
          deletable_dbs.sort.each do |db|
            puts db
          end
          Interaction.note "These #{dbtype} databases are not allowlisted and can be deleted."
          proceed = Interaction.prompt('Proceed? [y]es, [n]o or [e]dit allowlist')
        end
        case proceed
        when 'e'
          proceed = '' # reset user selection
          edit_allowlist dbtype
        when 'n'
          Interaction.note 'Nothing deleted.'
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

    def is_allowlisted?(dbtype, database_name)
      allowlist_content = if File.exist? allowlist_fname(dbtype)
        Geordi::Util.stripped_lines(File.open(allowlist_fname(dbtype), 'r').read)
      else
        []
      end
      # Allow explicit allowlisting of derivative databases like projectname_test2
      if allowlist_content.include? database_name
        true
      # allowlisting `projectname` also allowlists `projectname_test\d*`, `projectname_development`
      elsif allowlist_content.include? database_name.sub(@derivative_dbname, '')
        true
      else
        false
      end
    end

    def filter_allowlisted(dbtype, database_list)
      # n.b. `delete` means 'delete from list of dbs that should be deleted in this context
      # i.e. `delete` means 'keep this database'
      deletable_dbs = database_list.dup
      deletable_dbs.delete_if { |db| is_allowlisted?(dbtype, db) if File.exist? allowlist_fname(dbtype) }
      deletable_dbs.delete_if { |db| is_protected?(dbtype, db) }
      deletable_dbs.delete_if { |db| db.start_with? '#' }
    end
    private :filter_allowlisted

    def legacy_allowlist_directory
      @legacy_allowlist_directory ||= File.join(@base_directory, '.config', 'geordi', 'whitelists')
    end

    def move_allowlist_files
      %w[postgres mysql].each do |dbtype|
        new_path = allowlist_fname(dbtype)
        next if File.exist?(new_path)

        legacy_path = File.join(legacy_allowlist_directory, dbtype) << '.txt'
        FileUtils.mv(legacy_path, new_path)

        if Dir.exist?(legacy_allowlist_directory) && Dir.empty?(legacy_allowlist_directory)
          Dir.delete(legacy_allowlist_directory)
        end
      end
    end
  end
end
