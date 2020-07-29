Feature: The rspec command

  Background:
    Given a file named "spec/spec_helper.rb" with "enable rspec"

  Scenario: A rspec binstub is used if present
    Given a file named "bin/rspec" with "binstub"

    When I run `geordi rspec`
    Then the output should contain "Util.system! bin/rspec"

  Scenario: A rake binstub is used to run parallel tests if present
    Given a file named "bin/rake" with "binstub"
      And a file named "Gemfile" with "gem 'parallel_tests'"

    When I run `geordi rspec`
    Then the output should contain "Util.system! bin/rake, parallel:spec"
