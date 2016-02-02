Feature: The console command

  Scenario: Opening a local Rails console
    When I run `geordi console`
    Then the output should contain "# Opening a local Rails console"
      And the output should contain "Util.system! bundle exec rails console development"
