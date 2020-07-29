Feature: The rake command

  Background:
    Given a file named "config/environments/development.rb" with "enable environment"

  Scenario: A rake binstub is used if present
    Given a file named "bin/rake" with "binstub"

    When I run `geordi rake`
    Then the output should contain "Util.system! bin/rake"
