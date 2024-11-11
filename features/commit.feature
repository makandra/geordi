Feature: Creating a git commit from a Linear issue
  Background:
    Given a file named "tmp/global_settings.yml" with "linear_api_key: my_api_key"


  Scenario: If there are no issues, the command fails
    Given there are no Linear issues

    When I run `geordi commit`
    Then the output should contain "No issues to offer."


  Scenario: It creates a commit with the linear issue url as description
    Given I have staged changes

    When I run `geordi commit` interactively
      # No optional message
    And I type ""
    Then the output should contain "Util.run! git, commit, --allow-empty, -m, [team-123] Test Issue, -m, Issue: https://www.issue-url.com"


  Scenario: Extra arguments are forwarded to "git commit"
    Given I have staged changes

    When I run `geordi commit --extra-option` interactively
      # No optional message
      And I type ""
    Then the output should contain "Util.run! git, commit, --allow-empty, -m, [team-123] Test Issue, -m, Issue: https://www.issue-url.com, --extra-option"


  Scenario: With no staged changes, a warning is printed
    When I run `geordi commit --allow-empty` interactively
      And I type "optional message"
    Then the output should contain "> No staged changes. Will create an empty commit."


  Scenario: Without a global config file, the user is prompted for their Linear API key
    Given I remove the file "tmp/global_settings.yml"
    When I run `geordi commit` interactively
      And I type "my_api_key"
      And I type "optional message"
    Then the file "tmp/global_settings.yml" should contain "linear_api_key: my_api_key"
      And the output should contain "Util.run! git, commit"


  Scenario: It does not crash on an empty config file
    Given a file named "tmp/local_settings.yml" with ""

    When I run `geordi commit` interactively
      And I type "optional message"
    Then the output should contain "Util.run! git, commit, --allow-empty, -m, [team-123] Test Issue - optional message"
