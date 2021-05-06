require 'yaml'

require File.expand_path('util', __dir__)
require File.expand_path('interaction', __dir__)

module Geordi
  class Settings
    GLOBAL_SETTINGS_FILE_NAME = Util.testing? ? './tmp/global_settings.yml'.freeze : File.join(ENV['HOME'], '.config/geordi/global.yml').freeze
    LOCAL_SETTINGS_FILE_NAME = Util.testing? ? './tmp/local_settings.yml'.freeze : './.geordi.yml'.freeze

    ALLOWED_GLOBAL_SETTINGS = %w[ pivotal_tracker_api_key auto_update_chromedriver pivotal_tracker_project_ids ].freeze
    ALLOWED_LOCAL_SETTINGS = %w[ pivotal_tracker_project_ids ].freeze

    SETTINGS_WARNED = 'GEORDI_INVALID_SETTINGS_WARNED'

    def initialize
      read_settings
    end

    # Global settings
    def pivotal_tracker_api_key
      @global_settings['pivotal_tracker_api_key'] || gitpt_api_key_old || inquire_pt_api_key
    end

    def pivotal_tracker_api_key=(value)
      @global_settings['pivotal_tracker_api_key'] = value
      save_global_settings
    end

    def auto_update_chromedriver
      @global_settings["auto_update_chromedriver"] || false
    end

    def auto_update_chromedriver=(value)
      @global_settings['auto_update_chromedriver'] = value
      save_global_settings
    end

    def pivotal_tracker_project_ids
      local_project_ids = @local_settings['pivotal_tracker_project_ids'] || pt_project_ids_old
      global_project_ids = @global_settings['pivotal_tracker_project_ids']

      local_project_ids = array_wrap_project_ids(local_project_ids)
      global_project_ids = array_wrap_project_ids(global_project_ids)

      project_ids = local_project_ids | global_project_ids

      if project_ids.empty?
        puts
        Geordi::Interaction.warn "Sorry, I could not find a project ID in .geordi.yml :("
        puts

        puts "Please put at least one Pivotal Tracker project id into the .geordi.yml file in this directory, e.g."
        puts
        puts "pivotal_tracker_project_ids:"
        puts "- 123456"
        puts
        puts 'You may add multiple IDs.'
        exit 1
      end

      project_ids
    end

    private

    def read_settings
      global_path = GLOBAL_SETTINGS_FILE_NAME
      local_path = LOCAL_SETTINGS_FILE_NAME

      global_settings = if File.exists?(global_path)
        YAML.safe_load(File.read(global_path))
      end
      local_settings = if File.exists?(local_path)
        YAML.safe_load(File.read(local_path))
      end

      # Prevent duplicate warnings caused by another instance of Settings
      unless ENV[SETTINGS_WARNED]
        check_for_invalid_keys(global_settings, ALLOWED_GLOBAL_SETTINGS, global_path)
        check_for_invalid_keys(local_settings, ALLOWED_LOCAL_SETTINGS, local_path)
        Interaction.warn "Unsupported config file \".firefox-version\". Please remove it." if File.exists?('.firefox-version')

        ENV[SETTINGS_WARNED] = 'true'
      end

      @global_settings = global_settings || {}
      @local_settings = local_settings || {}
    end

    def check_for_invalid_keys(settings, allowed_keys, file)
      return if settings.nil?

      invalid_keys = settings.keys - allowed_keys
      unless invalid_keys.empty?
        Interaction.warn "Unknown settings in #{file}: #{invalid_keys.join(", ")}"
        Interaction.note "Supported settings in #{file} are: #{allowed_keys.join(", ")}"
      end
    end

    def save_global_settings
      global_path = GLOBAL_SETTINGS_FILE_NAME
      global_directory = File.dirname(global_path)
      FileUtils.mkdir_p(global_directory) unless File.directory? global_directory
      File.open(global_path, 'w') do |file|
        file.write @global_settings.to_yaml
      end
    end

    # deprecated
    def gitpt_api_key_old
      file_path = File.join(ENV['HOME'], '.gitpt')
      if File.exist?(file_path) && !Util.testing?
        token = YAML.load_file(file_path).fetch :token
        self.pivotal_tracker_api_key = token

        Geordi::Interaction.warn "The ~/.gitpt file is deprecated."
        Geordi::Interaction.note "The contained setting has been moved to ~/.config/geordi/global.yml."
        Geordi::Interaction.note "If you don't need to work with an older version of geordi you can delete ~/.gitpt now."

        token
      end
    end

    def inquire_pt_api_key
      Geordi::Interaction.warn 'Your settings are missing or invalid.'
      Geordi::Interaction.warn "Please configure your Pivotal Tracker access."
      token = Geordi::Interaction.prompt('Your API key:').to_s # Just be sure
      self.pivotal_tracker_api_key = token
      puts

      token
    end

    # deprecated
    def pt_project_ids_old
      if File.exist?('.pt_project_id')
        project_ids = File.read('.pt_project_id')
        puts # Make sure to start on a new line (e.g. when invoked after a #print)
        Geordi::Interaction.warn "The usage of the .pt_project_id file is deprecated."
        Geordi::Interaction.note Util.strip_heredoc(<<-INSTRUCTIONS)
          Please remove this file from your project and add or extend the .geordi.yml file with the following content:
            pivotal_tracker_project_ids: #{project_ids}
        INSTRUCTIONS

        project_ids
      end
    end

    def array_wrap_project_ids(project_ids)
      case project_ids
      when Array
        project_ids
      when String
        project_ids.split(/[\s]+/).map(&:to_i)
      when Integer
        [project_ids]
      else
        []
      end
    end

  end
end
