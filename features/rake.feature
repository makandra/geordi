Feature: The rake command

  Scenario: When a bin/rake file exists, it is executed
    Given an empty file named "bin/rake"

    When I run `geordi rake` interactively
    Then the output should contain "Util.system! bin/rake"
