@same-process
Feature: The docker command

  Scenario: Setup checks for existence of docker
    Given the docker command cannot find the "docker" binary
    When I run `geordi docker setup`
    Then the output should contain "which docker"
      And the output should contain "x You need to install docker first"


  Scenario: Setup checks for existence of docker-compose
    Given the docker command cannot find the "docker-compose" binary
    When I run `geordi docker setup`
    Then the output should contain "which docker-compose"
      And the output should contain "x You need to install docker-compose first"


  Scenario: Setup checks for existence of docker-compose.yml
    When I run `geordi docker setup`
    Then the output should contain "x Your project does not seem to be properly set up."


  Scenario: Setup checks for service named "main"
    Given a file named "docker-compose.yml" with:
    """
    foo: bar
    """

    When I run `geordi docker setup`
    Then the output should contain "x Your project does not seem to be properly set up."


  Scenario: Setup runs docker-compose pull
    Given a file named "docker-compose.yml" with:
    """
    services:
      main: foo
    """

    When I run `geordi docker setup`
    Then the output should contain "docker-compose pull"


  Scenario: Shell checks for existence of docker
    Given the docker command cannot find the "docker" binary
    When I run `geordi docker shell`
    Then the output should contain "which docker"
      And the output should contain "x You need to install docker first"


  Scenario: Shell runs docker-compose run main, and docker-compose stop
    Given a file named "docker-compose.yml" with:
    """
    services:
      main: foo
    """
      And I set the environment variables to:
        | variable      | value             |
        | SSH_AUTH_SOCK | /path/to/sock/ssh |

    When I run `geordi docker shell`
    Then the output should contain "docker-compose run --service-ports -v /path/to/sock:/path/to/sock -e SSH_AUTH_SOCK=/path/to/sock/ssh main"
    Then the output should contain "docker-compose stop"


  Scenario: One can attach to a running shell
    Given the docker command finds a running shell "project_main_run_foo"
      And a file named "docker-compose.yml" with:
    """
    services:
      main: foo
    """

    When I run `geordi docker shell --secondary`
    Then the output should contain "docker exec -it project_main_run_foo bash"


  Scenario: Attaching fails if no shell is running
    Given a file named "docker-compose.yml" with:
    """
    services:
      main: foo
    """

    When I run `geordi docker shell --secondary`
    Then the output should contain "Could not find a running shell"
