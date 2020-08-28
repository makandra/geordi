class Gitpt
  require 'yaml'
  require 'highline'
  require 'tracker_api'

  # This require-style is to prevent Ruby from loading files of a different
  # version of Geordi.
  require File.expand_path('settings', __dir__)

  def initialize
    self.highline = HighLine.new
    self.settings = Geordi::Settings.new
    self.client = build_client
  end

  def run(git_args)
    Geordi::Interaction.warn <<-WARNING unless Geordi::Util.staged_changes?
No staged changes. Will create an empty commit.
    WARNING

    story = choose_story
    if story
      create_commit "[##{story.id}] #{story.name}", *git_args
    end
  end

  private

  attr_accessor :highline, :client, :settings

  def build_client
    TrackerApi::Client.new(token: settings.pivotal_tracker_api_key)
  end

  def load_projects
    project_ids = settings.pivotal_tracker_project_ids
    project_ids.collect { |project_id| client.project(project_id) }
  end

  def applicable_stories
    projects = load_projects
    projects.collect do |project|
      project.stories(filter: 'state:started,finished,rejected')
    end.flatten
  end

  def choose_story
    if Geordi::Util.testing?
      return OpenStruct.new(id: 12, name: 'Test Story')
    end

    loading_message = 'Connecting to Pivotal Tracker ...'
    print(loading_message)
    stories = applicable_stories
    reset_loading_message = "\r#{' ' * (loading_message.length + stories.length)}\r"

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
    message << ' - ' << extra if extra != ''

    Geordi::Util.run! 'git', 'commit', '--allow-empty', '-m', message, *git_args
  end

  def bold(string)
    HighLine::BOLD + string + HighLine::RESET
  end

end
