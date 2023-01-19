Feature: Creating a git commit from a Pivotal Tracker story
  Background:
    Given a file named "tmp/global_settings.yml" with "pivotal_tracker_api_key: my_api_key"


  Scenario: If there are no stories, the command fails
    Given there are no stories

    When I run `geordi commit`
    Then the output should contain "No stories to offer."

  Scenario: It creates a commit with the pivotal tracker story url as description
    Given I have staged changes

    When I run `geordi commit` interactively
      # No optional message
      And I type ""
    Then the output should contain "Util.run! git, commit, --allow-empty, -m, [#12] Test Story, -m, Story: https://www.story-url.com"


  Scenario: Extra arguments are forwarded to "git commit"
    Given I have staged changes

    When I run `geordi commit --extra-option` interactively
      # No optional message
      And I type ""
    Then the output should contain "Util.run! git, commit, --allow-empty, -m, [#12] Test Story, -m, Story: https://www.story-url.com, --extra-option"


  Scenario: With no staged changes, a warning is printed
    When I run `geordi commit --allow-empty` interactively
      And I type "optional message"
    Then the output should contain "> No staged changes. Will create an empty commit."


  Scenario: Without a global config file, the user is prompted for their PT API key
    Given I remove the file "tmp/global_settings.yml"
    When I run `geordi commit` interactively
      And I type "my_api_key"
      And I type "optional message"
    Then the file "tmp/global_settings.yml" should contain "pivotal_tracker_api_key: my_api_key"


  Scenario: It does not crash on an empty config file
    Given a file named "tmp/local_settings.yml" with ""

    When I run `geordi commit` interactively
      And I type "optional message"
    Then the output should contain "Util.run! git, commit, --allow-empty, -m, [#12] Test Story - optional message"
