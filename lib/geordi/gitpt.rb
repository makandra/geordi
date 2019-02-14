class Gitpt
  include Geordi::Interaction
  require 'yaml'
  require 'highline'
  require 'tracker_api'

  SETTINGS_FILE_NAME = '.gitpt'
  PROJECT_IDS_FILE_NAME = '.pt_project_id'

  def initialize
    self.highline = HighLine.new
  end

  def run
    settings = read_settings
    client = build_client(settings)

    puts 'Connecting to Pivotal Tracker...'

    projects = load_projects(client)
    applicable_stories = load_applicable_stories(projects)
    choose_story(client.me, applicable_stories)
  end

  private

  attr_accessor :highline

  def read_settings
    file_path = File.join(ENV['HOME'], SETTINGS_FILE_NAME)

    unless File.exists?(file_path)
      highline.say HighLine::RESET
      highline.say "Welcome to #{bold 'gitpt'}.\n\n"

      highline.say highlight('Your settings are missing or invalid.')
      highline.say "Please configure your Pivotal Tracker access.\n\n"
      token = highline.ask bold("Your API key:") + " "
      highline.say "\n"

      settings = { :token => token }
      File.open(file_path, 'w') do |file|
        file.write settings.to_yaml
      end
    end

    YAML.load_file(file_path)
  end

  def build_client(settings)
    TrackerApi::Client.new(:token => settings.fetch(:token))
  end

  def load_projects(client)
    project_ids = read_project_ids

    project_ids.collect { |project_id| client.project(project_id) }
  end

  def read_project_ids
    file_path = PROJECT_IDS_FILE_NAME

    if File.exists?(file_path)
      project_ids = File.read('.pt_project_id').split(/[\s]+/).map(&:to_i)
    end

    if project_ids and project_ids.size > 0
      project_ids
    else
      warn "Sorry, I could not find a project ID in #{file_path} :("
      puts

      puts "Please put at least one Pivotal Tracker project id into #{file_path} in this directory."
      puts 'You may add multiple IDs, separated using white space.'
      exit 1
    end
  end

  def load_applicable_stories(projects)
    projects.collect { |project| project.stories(:filter => 'state:started,finished,rejected') }.flatten
  end

  def choose_story(me, applicable_stories)
    selected_story = nil

    highline.choose do |menu|
      menu.header = "Choose a story"
      applicable_stories.each do |story|
        state = story.current_state
        owners = story.owners
        owner_is_me = owners.collect(&:id).include?(me.id)

        if state == 'started'
          state = HighLine::GREEN + state + HighLine::RESET
        elsif state != 'finished'
          state = HighLine::RED + state + HighLine::RESET
        end

        state += HighLine::BOLD if owner_is_me

        label = "(#{owners.collect(&:name).join(', ')}, #{state}) #{story.name}"
        label = bold(label) if owner_is_me
        menu.choice(label) { selected_story = story }
      end
      menu.hidden ''
    end

    if selected_story
      message = highline.ask("\nAdd an optional message")
      highline.say message

      commit_message = "[##{selected_story.id}] #{selected_story.name}"
      if message.strip != ''
        commit_message << ' - '<< message.strip
      end

      exec('git', 'commit', '-m', commit_message)
    end
  end

  def bold(string)
    HighLine::BOLD + string + HighLine::RESET
  end

  def highlight(string)
    bold HighLine::BLUE + string
  end

end
