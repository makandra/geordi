require 'yaml'

require File.expand_path('util', __dir__)
require File.expand_path('interaction', __dir__)

module Geordi
  class Settings
    GLOBAL_SETTINGS_FILE_NAME = Util.testing? ? './tmp/global_settings.yml'.freeze : File.join(ENV['HOME'], '.config/geordi/global.yml').freeze
    LOCAL_SETTINGS_FILE_NAME = Util.testing? ? './tmp/local_settings.yml'.freeze : './.geordi.yml'.freeze

    ALLOWED_GLOBAL_SETTINGS = %w[
      auto_update_chromedriver
      hint_probability
      irb_flags
      linear_api_key
      linear_team_ids
    ].freeze

    ALLOWED_LOCAL_SETTINGS = %w[ linear_team_ids ].freeze

    SETTINGS_WARNED = 'GEORDI_INVALID_SETTINGS_WARNED'

    def initialize
      read_settings
    end

    # Global settings
    def irb_flags
      @global_settings['irb_flags']
    end

    def linear_api_key
      @global_settings['linear_api_key'] || begin
        Interaction.warn 'Linear API key not found'
        inquire_linear_api_key
      end
    end

    def linear_api_key=(value)
      @global_settings['linear_api_key'] = value
      save_global_settings
    end

    def hint_probability
      @global_settings['hint_probability']
    end

    def auto_update_chromedriver
      @global_settings["auto_update_chromedriver"] || false
    end

    def auto_update_chromedriver=(value)
      @global_settings['auto_update_chromedriver'] = value
      save_global_settings
    end

    def linear_team_ids
      local_team_ids = normalize_team_ids(@local_settings['linear_team_ids'])
      global_team_ids = normalize_team_ids(@global_settings['linear_team_ids'])

      team_ids = local_team_ids | global_team_ids

      if team_ids.empty?
        Geordi::Interaction.warn 'No team id found.'
        puts 'Please open a team in Linear, open the command menu with CTRL + K and choose'
        puts "\"Copy model UUID\". Store that team id in #{LOCAL_SETTINGS_FILE_NAME}:"
        puts 'linear_team_ids: abc-123-123-abc, def-456-456-def'
        exit 1
      end

      team_ids
    end

    private

    def read_settings
      global_path = GLOBAL_SETTINGS_FILE_NAME
      local_path = LOCAL_SETTINGS_FILE_NAME

      global_settings = if File.exist?(global_path)
        YAML.safe_load(File.read(global_path))
      end
      local_settings = if File.exist?(local_path)
        YAML.safe_load(File.read(local_path))
      end

      # Prevent duplicate warnings caused by another instance of Settings
      unless ENV[SETTINGS_WARNED]
        check_for_invalid_keys(global_settings, ALLOWED_GLOBAL_SETTINGS, global_path)
        check_for_invalid_keys(local_settings, ALLOWED_LOCAL_SETTINGS, local_path)
        Interaction.warn "Unsupported config file \".firefox-version\". Please remove it." if File.exist?('.firefox-version')

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
        puts "Supported settings in #{file} are: #{allowed_keys.join(", ")}"
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

    def inquire_linear_api_key
      Geordi::Interaction.note 'Create an API key here: https://linear.app/makandra/settings/api'
      token = Geordi::Interaction.prompt("Please enter the API key:")
      self.linear_api_key = token
      Interaction.note("API key stored in #{GLOBAL_SETTINGS_FILE_NAME}.")
      puts

      token
    end

    def normalize_team_ids(team_ids)
      case team_ids
      when Array
        team_ids
      when String
        team_ids.split(/[\s,;]+/)
      when Integer
        [team_ids]
      else
        []
      end
    end

  end
end
