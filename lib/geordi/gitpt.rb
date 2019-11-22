class Gitpt
  include Geordi::Interaction
  require 'yaml'
  require 'highline'
  require 'tracker_api'

  SETTINGS_FILE_NAME = '.gitpt'
  PROJECT_IDS_FILE_NAME = '.pt_project_id'

  def initialize
    self.highline = HighLine.new
    self.client = build_client(read_settings)
  end

  def run(git_args)
    warn <<-WARNING if !Geordi::Util.staged_changes?
No staged changes. Will create an empty commit.
    WARNING

    story = choose_story
    if story
      create_commit "[##{story.id}] #{story.name}", *git_args
    end
  end

  private

  attr_accessor :highline, :client

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

  def load_projects
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

  def applicable_stories
    projects = load_projects
    projects.collect do |project|
      project.stories(:filter => 'state:started,finished,rejected')
    end.flatten
  end

  def choose_story
    if Geordi::Util.testing?
      return OpenStruct.new(:id => 12, :name => 'Test Story')
    end

    loading_message = 'Connecting to Pivotal Tracker ...'
    print(loading_message)
    stories = applicable_stories
    reset_loading_message = "\r#{ ' ' * (loading_message.length + stories.length)}\r"

    highline.choose do |menu|
      menu.header = 'Choose a story'

      stories.each do |story|
        print '.' # Progress

        state = story.current_state
        owners = story.owners
        owner_is_me = owners.collect(&:id).include?(client.me.id)

        if state == 'started'
          state = HighLine::GREEN + state + HighLine::RESET
        elsif state != 'finished'
          state = HighLine::RED + state + HighLine::RESET
        end

        state += HighLine::BOLD if owner_is_me

        label = "(#{owners.collect(&:name).join(', ')}, #{state}) #{story.name}"
        label = bold(label) if owner_is_me

        menu.choice(label) { return story }
      end

      menu.hidden ''
      print reset_loading_message # Once menu is build
    end

    nil # Return nothing
  end

  def create_commit(message, *git_args)
    extra = highline.ask("\nAdd an optional message").strip
    message << ' - ' << extra if (extra != "")

    Geordi::Util.system! 'git', 'commit', '--allow-empty', '-m', message, *git_args
  end

  def bold(string)
    HighLine::BOLD + string + HighLine::RESET
  end

  def highlight(string)
    bold HighLine::BLUE + string
  end

end
