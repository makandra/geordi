Feature: The server/devserver command

  Scenario: Booting a development server
    When I run `geordi server`
    Then the output should contain "http://aruba.vcap.me:3000"
      And the output should contain "Util.system! bundle exec rails server -p 3000 -b 0.0.0.0"


  Scenario: Passing a port as argument
    When I run `geordi server 3001`
    Then the output should contain "http://aruba.vcap.me:3001"
      And the output should contain "Util.system! bundle exec rails server -p 3001 -b 0.0.0.0"


  Scenario: Passing a port as option
    When I run `geordi server -p 3001`
    Then the output should contain "http://aruba.vcap.me:3001"
    And the output should contain "Util.system! bundle exec rails server -p 3001 -b 0.0.0.0"


  Scenario: The command is aliased for backwards compatibility
    When I run `geordi devserver`
    Then the output should contain "Util.system! bundle exec rails server -p 3000 -b 0.0.0.0"

