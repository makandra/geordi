Feature: The firefox/chrome command

  Scenario: Running a command with VNC set up
    Given a file named "testfile" with "testcontent"

    When I run `geordi firefox ls`
    Then the output should contain "> VNC is ready to hold Selenium test browsers. Use `geordi vnc` to view them."
      And the output should contain "testfile"


  Scenario: The command is aliased as "chrome"
    Given a file named "testfile" with "testcontent"

    When I run `geordi chrome ls`
    Then the output should contain "> VNC is ready to hold Selenium test browsers. Use `geordi vnc` to view them."
      And the output should contain "testfile"
