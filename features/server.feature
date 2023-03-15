Feature: The server/devserver command

  Scenario: Booting a development server
    When I run `geordi server`
    Then the output should contain "http://aruba.daho.im:3000"
      And the output should contain "Util.run! bundle exec rails server -p 3000"


  Scenario: Passing a port as argument
    When I run `geordi server 3001`
    Then the output should contain "http://aruba.daho.im:3001"
      And the output should contain "Util.run! bundle exec rails server -p 3001"


  Scenario: Passing a port as option
    When I run `geordi server -p 3001`
    Then the output should contain "http://aruba.daho.im:3001"
    And the output should contain "Util.run! bundle exec rails server -p 3001"


  Scenario: The command is aliased for backwards compatibility
    When I run `geordi devserver`
    Then the output should contain "Util.run! bundle exec rails server"


  Scenario: Starting the server as accessible from the local network

    ... so it can be accessed from a test iPad or so.

    When I run `geordi server --public`
    Then the output should contain "Util.run! bundle exec rails server -b 0.0.0.0"
