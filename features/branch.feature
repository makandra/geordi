Feature: Check out a feature branch based on an issue from Linear
  Background:
    Given a file named "tmp/global_settings.yml" with "linear_api_key: my_api_key"

  Scenario: Checkout a new branch with geordi branch
    Given my local git branches are: master

    When I run `geordi branch` interactively
      And I type ""
    Then the output should contain "Util.run! git, checkout, -b, testuser/12-test-issue"


  Scenario: Checkout a new branch with geordi branch from master
    Given my local git branches are: master

    When I run `geordi branch --from-master` interactively
      And I type ""
    Then the output should contain "Util.run! git, checkout, master"
      And the output should contain "Util.run! git, checkout, -b, testuser/12-test-issue"


  Scenario: Checkout an existing branch with geordi branch
    Given my local git branches are: master, mm/test-issue-12

    When I run `geordi branch` interactively
      And I type ""
    Then the output should not contain "Util.run! git, checkout, master"
      And the output should contain "Util.run! git, checkout, mm/test-issue-12"


  Scenario: The interaction fails if the local git branches could not be determined
    When I run `geordi branch` interactively
    Then the output should contain "Could not determine local git branches"
