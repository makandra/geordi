Feature: Check out a feature branch based on a story from Pivotal Tracker
  Background:
    Given a file named "tmp/global_settings.yml" with "pivotal_tracker_api_key: my_api_key"

  Scenario: Checkout a new branch with geordi branch
    Given my username from git config is "Max Musterman"
      And my local git branches are: master

    When I run `geordi branch` interactively
      # I skip the initials prompt
      And I type ""
    Then the output should contain "Util.run! git, checkout, -b, mm/test-story-12"


  Scenario: Checkout a new branch with geordi branch from master
    Given my username from git config is "Max Musterman"
    And my local git branches are: master

    When I run `geordi branch --from-master` interactively
      # I skip the initials prompt
      And I type ""
    Then the output should contain "Util.run! git, checkout, master"
      And the output should contain "Util.run! git, checkout, -b, mm/test-story-12"


  Scenario: Checkout a new branch with custom initials
    Given my local git branches are: master

    When I run `geordi branch` interactively
      # I enter my custom initials
      And I type "ab"
    Then the output should contain "Util.run! git, checkout, -b, ab/test-story-12"
      And the file "tmp/global_settings.yml" should contain "pivotal_tracker_api_key: my_api_key\ngit_initials: ab"


  Scenario: Checkout an existing branch with geordi branch
    Given my username from git config is "Max Musterman"
      And my local git branches are: master, mm/test-story-12

    When I run `geordi branch` interactively
      # I skip the initials prompt
      And I type ""
    Then the output should not contain "Util.run! git, checkout, master"
      And the output should contain "Util.run! git, checkout, mm/test-story-12"


  Scenario: The interaction fails if the local git branches could not be determined
    When I run `geordi branch` interactively
    Then the output should contain "Could not determine local git branches"

  Scenario: Checkout a new branch with initials from global_settings.yml.yml
    Given a file named "tmp/global_settings.yml" with "pivotal_tracker_api_key: my_api_key\ngit_initials: jd"
    And my local git branches are: master

    When I run `geordi branch` interactively
    Then the output should contain "Using Git user initials from ./tmp/global_settings.yml"
      And the output should contain "Util.run! git, checkout, -b, jd/test-story-12"
