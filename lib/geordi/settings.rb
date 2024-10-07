require 'yaml'

require File.expand_path('util', __dir__)
require File.expand_path('interaction', __dir__)

module Geordi
  class Settings
    GLOBAL_SETTINGS_FILE_NAME = Util.testing? ? './tmp/global_settings.yml'.freeze : File.join(ENV['HOME'], '.config/geordi/global.yml').freeze
    LOCAL_SETTINGS_FILE_NAME = Util.testing? ? './tmp/local_settings.yml'.freeze : './.geordi.yml'.freeze

    ALLOWED_GLOBAL_SETTINGS = %w[
      auto_update_chromedriver
      git_initials
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
      @global_settings['linear_api_key'] || inquire_linear_api_key
    end

    def linear_api_key=(value)
      @global_settings['linear_api_key'] = value
      save_global_settings
    end

    def hint_probability
      @global_settings['hint_probability']
    end

    def git_initials
      @global_settings['git_initials']
    end

    def git_initials=(value)
      @global_settings['git_initials'] = value
      save_global_settings
    end

    def auto_update_chromedriver
      @global_settings["auto_update_chromedriver"] || false
    end

    def auto_update_chromedriver=(value)
      @global_settings['auto_update_chromedriver'] = value
      save_global_settings
    end

    def linear_team_ids
      local_team_ids = @local_settings['linear_team_ids']
      global_team_ids = @global_settings['linear_team_ids']

      local_team_ids = array_wrap_team_ids(local_team_ids)
      global_team_ids = array_wrap_team_ids(global_team_ids)

      team_ids = local_team_ids | global_team_ids

      if team_ids.empty?
        puts
        Geordi::Interaction.warn "Sorry, I could not find a team ID in .geordi.yml :("
        puts

        puts "Please put at least one Linear team id into the .geordi.yml file in this directory, e.g."
        puts
        puts "linear_team_ids:"
        puts "- 123456"
        puts
        puts 'You may add multiple IDs.'
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
      Geordi::Interaction.warn 'Your settings are missing or invalid.'
      Geordi::Interaction.warn "Please configure your Linear access."
      token = Geordi::Interaction.prompt('Your API key:').to_s # Just be sure
      self.linear_api_key = token
      puts

      token
    end

    def array_wrap_team_ids(team_ids)
      case team_ids
      when Array
        team_ids
      when String
        team_ids.split(/[\s]+/).map(&:to_i)
      when Integer
        [team_ids]
      else
        []
      end
    end

  end
end
