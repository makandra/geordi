Feature: The migrate command

  Background:
    Given a directory named "db/migrate"

  Scenario: Migrating with parallel_tests uses the rake binstub if it exists
    Given a file named "bin/rake" with "binstub"
      And a file named "Gemfile" with "gem parallel_tests"

    When I run `geordi migrate`
    Then the output should contain "Util.system! bin/rake, db:migrate parallel:prepare"
