Feature: The console command
  Most aspects of connection to a server are tested in shell feature.

  Scenario: Opening a local Rails console
    When I run `geordi console`
    Then the output should contain "# Opening a local Rails console"
      And the output should contain "Util.run! bundle exec rails console -e development -- --nomultiline"

  Scenario: Opening a remote Rails console
    Given a file named "Capfile" with "Capfile exists"
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
