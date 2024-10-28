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

    def commit(git_args)
      Interaction.warn <<~WARNING unless Util.staged_changes?
        No staged changes. Will create an empty commit.
      WARNING

      issue = choose_issue
      create_commit "[#{issue['identifier']}] #{issue['title']}", "Issue: #{issue['url']}", *git_args
    end

    def branch(from_master: false)
      issue = choose_issue

      local_branches = local_branch_names
      matching_local_branch = local_branches.find { |branch_name| branch_name == issue['branchName'] }
      matching_local_branch ||= local_branches.find { |branch_name| branch_name.include? issue['identifier'].to_s }

      if matching_local_branch.present?
        Util.run! ['git', 'checkout', matching_local_branch]
      else
        Util.run! ['git', 'checkout', 'master'] if from_master
        Util.run! ['git', 'checkout', '-b', issue['branchName']]
      end
    end

    private

    attr_accessor :highline, :settings

    def local_branch_names
      @local_branch_names ||= begin
        branch_list_string = if Util.testing?
                               ENV['GEORDI_TESTING_GIT_BRANCHES'].to_s
                             else
                               `git branch --format="%(refname:short)"`
                             end

        if branch_list_string.nil? || branch_list_string.strip.empty?
          Interaction.fail 'Could not determine local Git branches.'
        end

        branch_list_string.split("\n")
      end
    end

    def choose_issue
      if Util.testing?
        return dummy_issue_for_testing
      end

      loading_message = 'Connecting to Linear ...'
      print(loading_message)
      issues = fetch_linear_issues
      reset_loading_message = "\r#{' ' * (loading_message.length + issues.length)}\r"

      if issues.empty?
        print reset_loading_message
        Geordi::Interaction.fail('No issues to offer.')
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

        menu.hidden('') { Interaction.fail('No issue selected.') }
        print reset_loading_message # Once menu is build
      end

      nil # Return nothing
    end

    def dummy_issue_for_testing
      settings.linear_api_key
      ENV['GEORDI_TESTING_NO_LINEAR_ISSUES'] == 'true' ? Geordi::Interaction.fail('No issues to offer.') : {
        'identifier' => 'team-123',
        'title' => 'Test Issue',
        'url' => 'https://www.issue-url.com',
        'branchName' => 'testuser/team-123-test-issue',
        'assignee' => { 'name' => 'Test User', 'isMe' => true },
        'state' => { 'name' => 'In Progress' }
      }
    end

    def create_commit(title, description, *git_args)
      extra = highline.ask("\nAdd an optional message").strip
      title << ' - ' << extra if extra != ''
      Util.run!(['git', 'commit', '--allow-empty', '-m', title, '-m', description, *git_args])
    end

    def fetch_linear_issues
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
      response = query_api(<<~GRAPHQL, filter: filter)
        query Issues($filter: IssueFilter) {
          issues(filter: $filter) {
            nodes {
              title
              identifier
              url
              branchName
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

    def query_api(attributes, variables)
      uri = URI(API_ENDPOINT)

      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true

      query = [{ query: attributes.split.join(' '), variables: variables}].to_json

      request = Net::HTTP::Post.new(uri.path)
      request.body = query

      request['Content-Type'] = 'application/json'
      request['Authorization'] = settings.linear_api_key

      response = https.request(request)

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
  end
end
