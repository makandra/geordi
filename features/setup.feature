Feature: Project setup

  Scenario: A local bin/setup is preferred
    Given a file named "bin/setup" with "custom project setup"

    When I run `geordi setup`
    Then the output should contain "Running bin/setup"
      And the output should contain "Geordi's own setup routine is skipped"
      And the output should contain "Util.system! bin/setup"
      And the output should not contain "Creating databases"
    But the output should contain "Successfully set up the project"
