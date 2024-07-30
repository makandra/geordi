Feature: The unit command

  Background:
    Given a file named "test/test_helper.rb" with "enable unit tests"

  Scenario: A rake binstub is used if present
    Given a file named "bin/rake" with "binstub"

    When I run `geordi unit`
    Then the output should contain "Util.run! bin/rake, test"


  Scenario: A rake binstub is used to run parallel tests if present
    Given a file named "bin/rake" with "binstub"
      And a file named "Gemfile" with "gem 'parallel_tests'"

    When I run `geordi unit`
    Then the output should contain "All unit tests at once (using parallel_tests)"
      And the output should contain "Util.run! bin/rake, parallel:test"
