@ruby>=2.1
Feature: Creating a git commit from a Pivotal Tracker story

  Scenario: Extra arguments are forwarded to "git commit"
    Given I have staged changes

    When I run `geordi commit --extra-option` interactively
      # No optional message
      And I type ""
    Then the output should contain "Util.system! git, commit, --allow-empty, -m, [#12] Test Story, --extra-option"


  Scenario: With no staged changes, a warning is printed
    When I run `geordi commit --allow-empty` interactively
      # No optional message
      And I type ""
    Then the output should contain "> No staged changes. Will create an empty commit."
