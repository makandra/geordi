Feature: The firefox/chrome command

  This command is used internally by the cucumber command.

  Scenario: Running a command with VNC set up
    Given a file named "testfile" with "testcontent"

    When I run `geordi firefox cat testfile`
    Then the output should contain "> Run `geordi vnc` to view the Selenium test browsers"
      And the output should contain "testcontent"
    But the output should not contain "Firefox for Selenium"


  Scenario: The command is aliased as "chrome"
    Given a file named "testfile" with "testcontent"

    When I run `geordi chrome cat testfile`
    Then the output should contain "> Run `geordi vnc` to view the Selenium test browsers"
      And the output should contain "testcontent"

  Scenario: Having a .firefox-version that is not installed yet
    Given a file named ".firefox-version" with "1337"
      And a file named "testfile" with "testcontent"

    When I run `geordi firefox cat testfile` interactively
      And I type "yes"
    Then the output should contain "> Firefox 1337 not found"
      And the output should contain "Run tests anyway?"
      And the output should contain "testcontent"


  Scenario: A .firefox-version file with "system" is ignored (legacy support)
    Given a file named ".firefox-version" with "system"
      And a file named "testfile" with "testcontent"

    When I run `geordi firefox cat testfile`
    Then the output should contain "> Run `geordi vnc`"
      And the output should contain "testcontent"
    But the output should not contain "Firefox for Selenium"


  Scenario: Running --setup without a version prints an error
    When I run `geordi firefox --setup`
    Then the output should contain "Firefox version required"
