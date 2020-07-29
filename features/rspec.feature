Feature: The rspec command

  Background:
    Given an empty file named "spec/spec_helper.rb"

  Scenario: When a bin/rspec file exists, it is executed
    Given an empty file named "bin/rspec"

    When I run `geordi rspec` interactively
    Then the output should contain "Util.system! bundle exec bin/rspec"

  Scenario: When a bin/rake file exists, it is used to run parallel tests
    Given an empty file named "bin/rake"
      And a file named "Gemfile" with "gem parallel_tests"

    When I run `geordi rspec` interactively
    Then the output should contain "Util.system! bin/rake, parallel:spec"
