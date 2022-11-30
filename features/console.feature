Feature: The console command
  Most aspects of connection to a server are tested in shell feature.

  Scenario: Opening a local Rails console with an irb version < 1.2.0
    Given the irb version is "1.1.0"
    When I run `geordi console`
    Then the output should contain "# Opening a local Rails console"
    And the output should contain "Util.run! bundle exec rails console -e development"
    But the output should not contain "nomultiline"


  Scenario: Opening a local Rails console with an irb version between 1.2.0 and 1.2.6
    Given the irb version is "1.2.0"
    When I run `geordi console`
    Then the output should contain "# Opening a local Rails console"
      And the output should contain "Util.run! bundle exec rails console -e development -- --nomultiline"

  Scenario: Opening a local Rails console with irb version >= 1.2.6
    Given the irb version is "1.2.6"
    When I run `geordi console`
    Then the output should contain "# Opening a local Rails console"
    And the output should contain "Util.run! bundle exec rails console -e development"
    But the output should not contain "nomultiline"


  Scenario: Opening a remote Rails console with an irb version between 1.2 and 1.2.6
    Given the irb version is "1.2.0"
    And a file named "Capfile" with "Capfile exists"
    And a file named "config/deploy.rb" with "deploy file exists"
    And a file named "config/deploy/staging.rb" with:
    """
    set :deploy_to, '/var/www/example.com'
    set :user, 'user'
    server 'www.example.com'
    """
    When I run `geordi console staging`
    Then the output should contain "# Opening a Rails console on staging"
    And the output should contain "Util.run! ssh, user@www.example.com, -t, cd /var/www/example.com/current && bash --login -c 'bundle exec rails console -e  -- --nomultiline"
