Feature: The security-update command

  Scenario: Preparing the security-update
    Unfortunately, Aruba cannot run commands truly interactively. We need to
    answer prompts blindly, and check the output afterwards.

    When I run `geordi security-update` interactively
      # Answer prompt "Continue?"
      And I type "yes"

    Then the output should contain:
      """
      # Preparing for security update
      > Please read https://makandracards.com/makandra/1587 before applying security updates!
      > About to checkout production and pull.
      Continue? [y]
      """
      And the output should contain:
      """
      Util.run! git checkout production
      """
      And the output should contain:
      """
      > git pull
      Util.run! git pull

      > Successfully prepared for security update

      > Please apply the security update now and commit your changes.
      > When you are done, run `geordi security-update finish`.
      """


  Scenario: Finishing the security-update with staging and production deploy targets
    Given a file named "config/deploy/staging.rb" with "staging.rb exists"
      And a file named "config/deploy/production.rb" with "production.rb exists"

    When I run `geordi security-update finish` interactively
      # Answer prompt "Have you successfully run all tests?"
      And I type "yes"
      # Answer prompt "Continue?"
      And I type "yes"
      # Answer prompt "Deploy staging now?"
      And I type "yes"
      # Answer prompt "Is the deployment log okay and the application is still running on staging?"
      And I type "yes"
      # Answer prompt "Deploy other stages now?"
      And I type "yes"
      # Answer prompt "Is the application still running on all other stages and the logs are okay?"
      And I type "yes"
    Then the output should contain:
      """
      Util.run! git status --porcelain

      # Finishing security update
      > Working directory clean.
      Have you successfully run all tests? [n]
      """
      And the output should contain:
      """
      > About to: push production, checkout & pull master, merge production, push master.
      Continue? [n]
      """
      And the output should contain:
      """
      > git push
      Util.run! git push
      > git checkout master
      Util.run! git checkout master
      > git pull
      Util.run! git pull
      > git merge production
      Util.run! git merge production
      > git push
      Util.run! git push

      # Deployment
      > There is a staging environment.
      Deploy staging now? [y]
      """
      And the output should contain:
      """
      # Deploy staging
      > bundle exec cap staging deploy:migrations
      Util.run! bundle exec cap staging deploy:migrations
      Is the deployment log okay and the application is still running on staging? [y]
      """
      And the output should contain:
      """
      > Found the following other stages:
      production

      Deploy other stages now? [y]
      """
      And the output should contain:
      """
      # Deploy production
      > bundle exec cap production deploy:migrations
      Util.run! bundle exec cap production deploy:migrations
      Is the application still running on all other stages and the logs are okay? [y]
      """
      And the output should contain:
      """
      > Successfully pushed and deployed security update

      > Now send an email to customer and project lead, informing them about the update.
      > Do not forget to make a joblog on a security budget, if available.
      """

  Scenario: Finishing the security-update without deploy targets
    When I run `geordi security-update finish` interactively
      # Answer prompt "Have you successfully run all tests?"
      And I type "yes"
      # Answer prompt "Continue?"
      And I type "yes"
    Then the output should contain:
      """
      Util.run! git status --porcelain

      # Finishing security update
      > Working directory clean.
      Have you successfully run all tests? [n]
      """
    And the output should contain:
      """
      > About to: push production, checkout & pull master, merge production, push master.
      Continue? [n]
      """
    And the output should contain:
      """
      > git push
      Util.run! git push
      > git checkout master
      Util.run! git checkout master
      > git pull
      Util.run! git pull
      > git merge production
      Util.run! git merge production
      > git push
      Util.run! git push

      # Deployment

      x There are no deploy targets!
      """

  Scenario: Finishing the security-update without staging target
    Given a file named "config/deploy/production.rb" with "production.rb exists"
    When I run `geordi security-update finish` interactively
      # Answer prompt "Have you successfully run all tests?"
      And I type "yes"
      # Answer prompt "Continue?"
      And I type "yes"
      # Answer prompt "Deploy other stages now?"
      And I type "yes"
      # Answer prompt "Is the application still running on all other stages and the logs are okay?"
      And I type "yes"

     # Only relevant output excerpt
    Then the output should contain:
      """
      # Deployment
      > There is no staging environment.

      > Found the following other stages:
      production

      Deploy other stages now? [y]
      """

  Scenario: Finishing the security-update with only staging target
    Given a file named "config/deploy/staging.rb" with "staging.rb exists"
    When I run `geordi security-update finish` interactively
      # Answer prompt "Have you successfully run all tests?"
      And I type "yes"
      # Answer prompt "Continue?"
      And I type "yes"
      # Answer prompt "Deploy staging now?"
      And I type "yes"
      # Answer prompt "Is the deployment log okay and the application is still running on staging?"
      And I type "yes"

     # Only relevant output excerpt
    Then the output should contain:
      """
      # Deployment
      > There is a staging environment.
      Deploy staging now? [y]
      """
      And the output should contain:
      """
      # Deploy staging
      > bundle exec cap staging deploy:migrations
      Util.run! bundle exec cap staging deploy:migrations
      Is the deployment log okay and the application is still running on staging? [y]
      """
      And the output should contain:
      """
      > There are no other stages.

      > Successfully pushed and deployed security update

      > Now send an email to customer and project lead, informing them about the update.
      > Do not forget to make a joblog on a security budget, if available.
      """
