require 'rubygems'
require 'highline'
require 'geordi/interaction'
require 'geordi/util'

module Geordi
  class DumpLoader

    def initialize(file, database)
      @dump_file = file
      @database = database
    end

    def development_database_config
      return @config if @config

      require 'yaml'

      evaluated_config_file = ERB.new(File.read('config/database.yml')).result

      # Allow aliases and a special set of classes like symbols and time objects
      permitted_classes = [Symbol, Time]
      database_config = if Gem::Version.new(Psych::VERSION) >= Gem::Version.new('3.1.0')
        YAML.safe_load(evaluated_config_file, permitted_classes: permitted_classes, aliases: true)
      else
        YAML.safe_load(evaluated_config_file, permitted_classes, [], true)
      end

      development_config = database_config['development']

      if development_config.values[0].is_a? Hash # Multi-db setup
        @config = if @database
          development_config[@database] || Interaction.fail(%(Unknown development database "#{@database}".))
        elsif development_config.has_key? 'primary'
          development_config['primary']
        else
          development_config.values[0]
        end
      else # Single-db setup
        if @database
          Interaction.fail %(Could not select "#{@database}" database in a single-db setup.)
        else
          @config = development_config
        end
      end

      @config
    end
    alias_method :config, :development_database_config

    def mysql_command
      command = 'mysql --silent'
      command << ' -p' << config['password'].to_s if config['password']
      command << ' -u' << config['username'].to_s if config['username']
      command << ' --port=' << config['port'].to_s if config['port']
      command << ' --host=' << config['host'].to_s if config['host']
      command << ' --default-character-set=utf8'
      command << ' ' << config['database'].to_s
      command << ' < ' << dump_file
    end
    alias_method :mysql2_command, :mysql_command

    def postgresql_command
      ENV['PGPASSWORD'] = config['password']
      command = 'pg_restore --no-owner --clean --no-acl'
      command << ' --username=' << config['username'].to_s if config['username']
      command << ' --port=' << config['port'].to_s if config['port']
      command << ' --host=' << config['host'].to_s if config['host']
      command << ' --dbname=' << config['database'].to_s
      command << ' ' << dump_file
    end

    def dump_file
      @dump_file ||= begin
        dumps_glob = File.join(File.expand_path('~'), 'dumps', '*.dump')
        available_dumps = Dir.glob(dumps_glob).sort

        HighLine.new.choose(*available_dumps) do |menu|
          menu.hidden('') { Interaction.fail 'Abort.' }
        end
      end
    end

    def load
      adapter_command = "#{config['adapter']}_command"
      Interaction.fail "Unknown database adapter #{config['adapter'].inspect} in config/database.yml." unless respond_to? adapter_command

      Interaction.note 'Source file: ' + dump_file

      source_command = send(adapter_command)
      Util.run! source_command, fail_message: "An error occurred loading #{File.basename(dump_file)}"
    end

  end
end
