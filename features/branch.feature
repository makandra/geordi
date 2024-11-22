Feature: Check out a feature branch based on an issue from Linear
  Background:
    Given a file named "tmp/global_settings.yml" with "linear_api_key: my_api_key"

  Scenario: Checkout a new branch with geordi branch
    Given my local git branches are: master

    When I run `geordi branch`
    Then the output should contain "Util.run! git, checkout, -b, testuser/team-123-test-issue"


  Scenario: Checkout a new branch from master
    Given my local git branches are: master

    When I run `geordi branch --from-master`
    Then the output should contain "Util.run! git, checkout, master"
      And the output should contain "Util.run! git, checkout, -b, testuser/team-123-test-issue"


  Scenario: Checkout a new branch from main
    Given my local git branches are: main
      And my default branch is "main"

    When I run `geordi branch --from-main`
    Then the output should contain "Util.run! git, checkout, main"
      And the output should contain "Util.run! git, checkout, -b, testuser/team-123-test-issue"


  Scenario: If the target branch already exists, just check it out
    Given my local git branches are: master, testuser/team-123-test-issue

    When I run `geordi branch`
    Then the output should contain "Util.run! git, checkout, testuser/team-123-test-issue"


  Scenario: The command fails if local Git branches can not be determined
    When I run `geordi branch`
    Then the output should contain "Could not determine local Git branches"
