require 'yaml'
require 'highline'
require 'tracker_api'

module Geordi
  class Gitpt

    # This require-style is to prevent Ruby from loading files of a different
    # version of Geordi.
    require File.expand_path('settings', __dir__)

    def initialize
      self.highline = HighLine.new
      self.settings = Settings.new
      self.client = build_client
    end

    def run_commit(git_args)
      Interaction.warn <<-WARNING unless Util.staged_changes?
No staged changes. Will create an empty commit.
      WARNING

      story = choose_story
      if story
        create_commit "[##{story.id}] #{story.name}", *git_args
      end
    end

    def run_branch
      story = choose_story || Interaction.fail('No story selected.')

      normalized_story_name = normalize_string(story.name)

      branch_list_string = if Util.testing?
        ENV['GEORDI_TESTING_GIT_BRANCHES'] || ''
      else
        `git branch --format="%(refname:short)"`
      end

      if branch_list_string.nil? || branch_list_string.strip.empty?
        Interaction.fail 'Could not determine local git branches.'
      end

      new_branch_name = "#{git_user_initials}/#{normalized_story_name}-#{story.id}"

      local_branches = branch_list_string.split("\n")
      branch_name = local_branches.find { |branch_name| branch_name == new_branch_name }
      branch_name ||= local_branches.find { |branch_name| branch_name.include? story.id.to_s }

      if branch_name.present?
        checkout_branch branch_name, new_branch: false
      else
        checkout_branch new_branch_name, new_branch: true
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
      if Util.testing?
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

      Util.run!(['git', 'commit', '--allow-empty', '-m', message, *git_args])
    end

    def bold(string)
      HighLine::BOLD + string + HighLine::RESET
    end

    def checkout_branch(name, new_branch: false)
      if new_branch
        Util.run! ['git', 'checkout', 'master']
        Util.run! ['git', 'checkout', '-b', name]
      else
        Util.run! ['git', 'checkout', name]
      end
    end

    def normalize_string(name)
      name.gsub!('ä', 'ae')
      name.gsub!('ö', 'oe')
      name.gsub!('ü', 'ue')
      name.gsub!('ß', 'ss')
      name.tr!('^A-Za-z0-9_ ', '')
      name.squeeze! ' '
      name.gsub!(' ', '-')
      name.downcase!
      name
    end

    def git_user_initials
      stdout_str = if Util.testing?
        ENV['GEORDI_TESTING_GIT_USERNAME']
      else
        `git config user.name`
      end

      git_user_initials = unless stdout_str.nil?
        stdout_str.strip.split(' ').map(&:chars).map(&:first).join.downcase
      end

      git_user_initials = Interaction.prompt 'Enter your initals:', git_user_initials

      if git_user_initials.nil?
        Interaction.fail('Could not determine the git user\'s initials.')
      else
        git_user_initials
      end
    end
  end
end
