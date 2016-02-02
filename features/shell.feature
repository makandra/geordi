Feature: The shell command

  Background:
    Given a file named "Capfile" with "Capfile exists"


  Scenario: It opens a remote shell on the primary server
    Given a file named "config/deploy.rb" with "deploy.rb exists"
    And a file named "config/deploy/geordi.rb" with:
    """
    set :user, 'deploy'
    set :deploy_to, '/var/www/example.com'
    server 'first.example.com'
    server 'second.example.com'
    """

    When I run `geordi shell geordi`
    Then the output should contain "Util.system! ssh deploy@first.example.com -t cd /var/www/example.com/current && bash --login"


  Scenario: It understands Capistrano 3 syntax
    Given a file named "config/deploy.rb" with "deploy.rb exists"
    And a file named "config/deploy/geordi.rb" with:
    """
    set :deploy_to, '/var/www/example.com'
    server 'first.example.com', user: 'deploy'
    """

    When I run `geordi shell geordi`
    Then the output should contain "Util.system! ssh deploy@first.example.com -t cd /var/www/example.com/current && bash --login"
