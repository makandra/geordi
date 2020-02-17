require 'rubygems'
require 'highline'
require 'geordi/interaction'
require 'geordi/util'

module Geordi
  class DumpLoader
    include Geordi::Interaction

    def initialize(file)
      @dump_file = file
    end

    def development_database_config
      require 'yaml'

      @config ||= YAML::load(ERB.new(File.read('config/database.yml')).result)
      @config['development']
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
      command = 'pg_restore --no-owner --clean'
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
          menu.hidden('') { fail 'Abort.' }
        end
      end
    end

    def load
      note 'Source file: ' + dump_file

      source_command = send("#{config['adapter']}_command")
      Util.system! source_command, :fail_message => "An error occured loading #{File.basename(dump_file)}"
    end

  end
end
