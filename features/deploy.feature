Feature: The deploy command

  Background:
    Given a file named "Capfile" with "Capfile exists"
      And a file named "config/deploy.rb" with "deploy.rb exists"
      And a file named "config/deploy/staging.rb" with "staging.rb exists"


  Scenario: Deploying from master to staging

    Unfortunately, Aruba cannot run commands truly interactively. We need to
    answer prompts blindly, and check the output afterwards.

    When I run `geordi deploy` interactively
      # Answer three prompts
      And I type "staging"
      And I type "master"
      And I type ""
      # Confirm deployment
      And I type "yes"
    Then the output should contain:
      """
      # You are about to:
      > Deploy to staging
      Go ahead with the deployment? [n]
      """
    And the output should contain:
      """
      > cap staging deploy:migrations
      Util.run! cap staging deploy:migrations

      > Deployment complete.
      """


  Scenario: Deploying the current branch

    Deploying the current branch requires support by the deployed application:
    its deploy config needs to pick up the DEPLOY_BRANCH environment variable.

    When I run `geordi deploy --current-branch` interactively
      # Answer deployment stage prompt
      And I type "staging"
    Then the output should contain "configure config/deploy/staging.rb"
      And the output should contain "ENV['DEPLOY_BRANCH']"

    Given a file named "config/deploy/staging.rb" with:
      """
      set :branch, ENV['DEPLOY_BRANCH'] || 'master'
      """
    When I run `geordi deploy --current-branch` interactively
      # Answer deployment stage prompt
      And I type "staging"
      # Confirm deployment
      And I type "yes"
    # Current branch is always "master" during tests
    Then the output should contain "From current branch master"
      And the output should contain "DEPLOY_BRANCH=master cap staging deploy:migrations"


  Scenario: Deploying with a given stage
    When I run `geordi deploy staging` interactively
      And I type "master"
      And I type ""
      And I type "no"
    Then the output should not contain "Deployment stage: [staging]"


  Scenario: Deploy with a default branch of "main"
    Given my default branch is "main"

    When I run `geordi deploy` interactively
    # Confirm prompts
    And I type ""
    And I type ""
    And I type ""
    And I type "no"

    Then the output should contain:
      """
      Deployment stage: [staging] Source branch: [main] Deploy branch: [main]
      """


Scenario: Deploying with custom stage and special branch
  Given a file named "config/deploy/custom.rb" with:
    """
    set :branch, ENV['DEPLOY_BRANCH'] || 'special'
    """

  When I run `geordi deploy custom` interactively
    # Confirm prompts
    And I type ""
    And I type ""
    And I type "no"

  Then the output should contain:
    """
    Source branch: [master] Deploy branch: [special]
    """
