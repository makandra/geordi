desc 'drop-databases', 'Delete local non-whitelisted databases'
long_desc <<-LONGDESC

Drop non-whitelisted databases from local installations of MySQL/MariaDB and
  PostgreSQL. Offers to edit the whitelist.
LONGDESC

option :postgres_only, :aliases => '-P', :type => :boolean,
  :desc => 'Only clean Postgres', :default => false
option :mysql_only, :aliases => '-M', :type => :boolean,
  :desc => 'Only clean MySQL/MariaDB', :default => false
option :postgres, :banner => 'STRING',
  :desc => 'Use Postgres port or socket'
option :mysql, :banner => 'STRING',
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

