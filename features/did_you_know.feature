Feature: Some commands print hints about related commands and options

  Scenario: A hint is displayed after running the rake command
    Given a file named "bin/rake" with "binstub"
    And a file named "tmp/global_settings.yml" with "hint_probability: 100"

    When I run `geordi rake`
    Then the output should contain "Did you know? `geordi capistrano` can run a Capistrano command on all deploy targets."
