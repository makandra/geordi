desc 'drop-databases', 'Interactively delete local databases'
long_desc <<-LONGDESC
Example: `geordi drop_databases`

Check both MySQL/MariaDB and Postgres on the machine running geordi for databases
and offer to delete them. Excluded are databases that are whitelisted. This comes
in handy when you're keeping your currently active projects in the whitelist files
and perform regular housekeeping with Geordi.

Per default, Geordi will try to connect to the databases as a local user without
password authorization.

Geordi will ask for confirmation before actually dropping databases and will
offer to edit the whitelist instead.
LONGDESC

option :postgres_only, aliases: '-P', type: :boolean,
  desc: 'Only clean PostgreSQL', default: false
option :mysql_only, aliases: '-M', type: :boolean,
  desc: 'Only clean MySQL/MariaDB', default: false
option :postgres, banner: 'PORT_OR_SOCKET',
  desc: 'Use PostgreSQL port or socket'
option :mysql, banner: 'PORT_OR_SOCKET',
  desc: 'Use MySQL/MariaDB port or socket'
option :sudo, aliases: '-S',  type: :boolean, default: false,
 desc: 'Access databases as root'

def drop_databases
  require 'geordi/db_cleaner'
  Interaction.fail '-P and -M are mutually exclusive' if options.postgres_only && options.mysql_only
  mysql_flags = nil
  postgres_flags = nil

  unless options.mysql.nil?
    begin
      mysql_port = Integer(options.mysql)
      mysql_flags = "--port=#{mysql_port} --protocol=TCP"
    rescue AttributeError
      unless File.exist? options.mysql
        Interaction.fail "Path #{options.mysql} is not a valid MySQL socket"
      end
      mysql_flags = "--socket=#{options.mysql}"
    end
  end

  unless options.postgres.nil?
    postgres_flags = "--port=#{options.postgres}"
  end

  unless options.sudo
    Interaction.note 'Assuming your local user has permission to drop databases. Run with `--sudo` to use sudo.'
  end

  extra_flags = {
    'mysql' => mysql_flags,
    'postgres' => postgres_flags,
  }
  cleaner = DBCleaner.new(extra_flags, sudo: options.sudo)
  cleaner.clean_mysql unless options.postgres_only
  cleaner.clean_postgres unless options.mysql_only

  Hint.did_you_know [
    :delete_dumps,
  ]
end
