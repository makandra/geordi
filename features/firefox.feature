Feature: The firefox/chrome command

  This command is used internally by the cucumber command.

  Scenario: Running a command with VNC set up
    Given a file named "testfile" with "testcontent"

    When I run `geordi firefox cat testfile`
    Then the output should contain "> VNC is ready to hold Selenium test browsers. Use `geordi vnc` to view them."
      And the output should contain "testcontent"
    But the output should not contain "Firefox for Selenium"


  Scenario: The command is aliased as "chrome"
    Given a file named "testfile" with "testcontent"

    When I run `geordi chrome cat testfile`
    Then the output should contain "> VNC is ready to hold Selenium test browsers. Use `geordi vnc` to view them."
      And the output should contain "testcontent"


    # Could not get this to work
#  Scenario: Running a command with VNC and Firefox set up
#    Given a mocked home directory
#    Given a file named ".firefox-version" with "1337"
#      And a file named "bin/firefoxes/1337/firefox" with "<fake>"
#      And a file named "testfile" with "testcontent"
#
#    When I run `geordi firefox cat testfile`
#    Then the output should contain "> VNC is ready"
#      And the output should contain "> Firefox for Selenium set up"
#      And the output should contain "testcontent"


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
    Then the output should contain "> VNC is ready"
      And the output should contain "testcontent"
    But the output should not contain "Firefox for Selenium"
