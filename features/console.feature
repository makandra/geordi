Feature: The console command
  Most aspects of connection to a server are tested in shell feature.

  Scenario: Opening a local Rails console
    When I run `geordi console`
    Then the output should contain "# Opening a local Rails console"
      And the output should contain "Util.system! bundle exec rails console -e development"
