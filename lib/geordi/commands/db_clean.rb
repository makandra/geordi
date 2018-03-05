desc 'drop-databases', 'Delete local non-whitelisted databases'
long_desc <<-LONGDESC

Delete local MySQL/MariaDB and Postgres databases that are not whitelisted.

Example: `geordi drop_databases`

Check both MySQL/MariaDB and Postgres on the machine running geordi for databases
and offer to delete them. Excluded are databases that are whitelisted. This comes
in handy when you're keeping your currently active projects in the whitelist files
and perform regular housekeeping with Geordi.

When called with `-P` or `-M` options, only handles Postgres resp. MySQL/MariaDB.

When called with `--postgres <port or local socket>` or `--mysql <port or local socket>`,
will instruct the underlying management commands to use those connection methods
instead of the defaults. This is useful when running multiple installations.
LONGDESC

option :postgres_only, :aliases => '-P', :type => :boolean,
  :desc => 'Only clean Postgres', :default => false
option :mysql_only, :aliases => '-M', :type => :boolean,
  :desc => 'Only clean MySQL/MariaDB', :default => false
option :postgres, :banner => 'PORT_OR_SOCKET',
  :desc => 'Use Postgres port or socket'
option :mysql, :banner => 'PORT_OR_SOCKET',
  :desc => 'Use MySQL/MariaDB port or socket'

def drop_databases
  require 'geordi/db_cleaner'
  fail '-P and -M are mutually exclusive' if options.postgres_only and options.mysql_only
  mysql_flags = nil
  postgres_flags = nil

  unless options.mysql.nil?
    begin
      mysql_port = Integer(options.mysql)
      mysql_flags = "--port=#{mysql_port} --protocol=TCP"
    rescue AttributeError
      unless File.exist? options.mysql
        fail "Path #{options.mysql} is not a valid MySQL socket"
      end
      mysql_flags = "--socket=#{options.mysql}"
    end
  end

  unless options.postgres.nil?
    postgres_flags = "--port=#{options.postgres}"
  end

  extra_flags = {'mysql' => mysql_flags,
                 'postgres' => postgres_flags
  }
  cleaner = DBCleaner.new(extra_flags)
  cleaner.clean_mysql unless options.postgres_only
  cleaner.clean_postgres unless options.mysql_only

  success 'Done.'
end

