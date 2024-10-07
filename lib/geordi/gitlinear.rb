require 'highline'
require 'net/http'
require 'json'
require 'active_support/core_ext/object/blank'

module Geordi
  class Gitlinear
    # This require-style is to prevent Ruby from loading files of a different
    # version of Geordi.
    require File.expand_path('settings', __dir__)

    API_ENDPOINT = 'https://api.linear.app/graphql'.freeze

    def initialize
      self.highline = HighLine.new
      self.settings = Settings.new
    end

    def run_commit(git_args)
      Interaction.warn <<~WARNING unless Util.staged_changes?
        No staged changes. Will create an empty commit.
      WARNING

      issue = choose_issue
      if issue
        create_commit "[#{issue['identifier']}] #{issue['title']}", "Issue: #{issue['url']}", *git_args
      end
    end

    def run_branch(from_master: false)
      issue = choose_issue || Interaction.fail('No issue selected.')

      normalized_issue_name = normalize_string(issue['title'])

      branch_list_string = if Util.testing?
                             ENV['GEORDI_TESTING_GIT_BRANCHES'] || ''
                           else
                             `git branch --format="%(refname:short)"`
                           end

      if branch_list_string.nil? || branch_list_string.strip.empty?
        Interaction.fail 'Could not determine local git branches.'
      end

      new_branch_name = "#{git_user_initials}/#{normalized_issue_name}-#{issue['identifier']}"
      local_branches = branch_list_string.split("\n")

      branch_name = local_branches.find { |branch_name| branch_name == new_branch_name }
      branch_name ||= local_branches.find { |branch_name| branch_name.include? issue['identifier'].to_s }

      if branch_name.present?
        checkout_branch branch_name, new_branch: false
      else
        checkout_branch new_branch_name, new_branch: true, from_master: from_master
      end
    end

    private

    attr_accessor :highline, :settings

    def choose_issue
      loading_message = 'Connecting to Linear ...'
      print(loading_message)
      issues = applicable_issues
      reset_loading_message = "\r#{' ' * (loading_message.length + issues.length)}\r"

      Geordi::Interaction.fail('No issues to offer.') if issues.empty?

      if Util.testing?
        return issues[0]
      end

      highline.choose do |menu|
        menu.header = 'Choose an issue'

        issues.each do |issue|
          state = issue['state']['name']
          if issue['assignee']
            assignee = issue['assignee']['name']
            assignee_is_me = issue['assignee']['isMe']
          else
            assignee = "none"
            assignee_is_me = false
          end

          if state == 'In Progress'
            state = HighLine::GREEN + state + HighLine::RESET
          else
            state = HighLine::RED + state + HighLine::RESET
          end

          state += HighLine::BOLD if assignee_is_me

          label = "(#{assignee}, #{state}) #{issue['title']}"
          label = bold(label) if assignee_is_me

          menu.choice(label) { return issue }
        end

        menu.hidden ''
        print reset_loading_message # Once menu is build
      end

      nil # Return nothing
    end

    def create_commit(title, description, *git_args)
      extra = highline.ask("\nAdd an optional message").strip
      title << ' - ' << extra if extra != ''
      Util.run!(['git', 'commit', '--allow-empty', '-m', title, '-m', description, *git_args])
    end

    def applicable_issues
      if Util.testing?
        settings.linear_api_key
        return ENV['GEORDI_TESTING_NO_LINEAR_ISSUES'] == 'true' ? [] : [{
                                                                          'identifier' => '12',
                                                                          'title' => 'Test Issue',
                                                                          'url' => 'https://www.issue-url.com'
                                                                        }]
      end

      team_ids = settings.linear_team_ids
      filter = {
        "team": {
          "id": {
            "in": team_ids,
          }
        },
        "state": {
          "type": {
            "eq": "started"
          }
        }
      }
      response = request_with_payload(<<~GRAPHQL, filter: filter)
        query Issues($filter: IssueFilter) {
          issues(filter: $filter) {
            nodes {
              title
              identifier
              url
              assignee {
                name
                isMe
              }
              state {
               name
             }
            }
          }
        }
      GRAPHQL

      response.dig(*%w[issues nodes])

    end

    def request_with_payload(attributes, variables)
      uri = URI(API_ENDPOINT)

      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true

      query = { query: attributes.split.join(' '), variables: variables}.to_json

      request = Net::HTTP::Post.new(uri.path)
      request.body = "[ #{query} ]"

      request['Content-Type'] = 'application/json'
      request['Authorization'] = settings.linear_api_key

      response = https.request(request)

      @last_response = response

      parsed_response = JSON.parse(response.body)[0]
      if parsed_response.key?('errors')
        raise parsed_response.dig('errors')
      else
        parsed_response['data']
      end
    end

    def bold(string)
      HighLine::BOLD + string + HighLine::RESET
    end

    def checkout_branch(name, new_branch: false, from_master: false)
      if new_branch
        Util.run! ['git', 'checkout', 'master'] if from_master
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
      if settings.git_initials
        Interaction.note "Using Git user initials from #{Settings::GLOBAL_SETTINGS_FILE_NAME}"
        return settings.git_initials
      end

      stdout_str = if Util.testing?
                     ENV['GEORDI_TESTING_GIT_USERNAME']
                   else
                     `git config user.name`
                   end

      git_user_initials = unless stdout_str.nil?
                            stdout_str.strip.split(' ').map(&:chars).map(&:first).join.downcase
                          end

      git_user_initials = Interaction.prompt 'Enter your initials:', git_user_initials

      if git_user_initials.nil?
        Interaction.fail('Could not determine the git user\'s initials.')
      else
        settings.git_initials = git_user_initials
        git_user_initials
      end
    end

  end
end
