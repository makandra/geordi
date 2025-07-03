Feature: The shell command

  Background:
    Given a file named "Capfile" with "Capfile exists"
      And a file named "config/deploy.rb" with "deploy.rb exists"


  Scenario: It opens a remote shell on the primary server when no option is given
    Given a file named "config/deploy/geordi.rb" with:
    """
    set :user, 'deploy'
    set :deploy_to, '/var/www/example.com'
    server 'first.example.com'
    server 'second.example.com'
    """

    When I run `geordi shell geordi`
    Then the output should contain "Util.run! ssh, deploy@first.example.com, -t, cd /var/www/example.com/current && bash --login"

  Scenario: It opens a menu to select the server to connect to when the select server option is given
    Given a file named "config/deploy/geordi.rb" with:
    """
    set :user, 'deploy'
    set :deploy_to, '/var/www/example.com'
    server 'first.example.com'
    server 'second.example.com'
    """

    When I run `geordi shell geordi --select-server` interactively
      # Answer prompt "Connect to? [1]"
      And I type "2"
    Then the output should contain "# Opening a shell on geordi"
    Then the output should contain "Util.run! ssh, deploy@second.example.com, -t, cd /var/www/example.com/current && bash --login"


  Scenario: It opens a remote shell on the selected server
    Given a file named "config/deploy/geordi.rb" with:
    """
    set :user, 'deploy'
    set :deploy_to, '/var/www/example.com'
    server 'first.example.com'
    server 'second.example.com'
    """

    When I run `geordi shell geordi --select-server 1`
    Then the output should contain "Util.run! ssh, deploy@first.example.com, -t, cd /var/www/example.com/current && bash --login"

    When I run `geordi shell geordi -s2`
    Then the output should contain "Util.run! ssh, deploy@second.example.com, -t, cd /var/www/example.com/current && bash --login"


  Scenario: It prints a warning and opens a menu to select the server to connect to when the server number is invalid
    Given a file named "config/deploy/geordi.rb" with:
    """
    set :user, 'deploy'
    set :deploy_to, '/var/www/example.com'
    server 'first.example.com'
    server 'second.example.com'
    """

    When I run `geordi shell geordi -s foo` interactively
      # Answer prompt "Connect to? [1]"
      And I type "2"
    Then the output should contain "> Invalid server number: foo"
    Then the output should contain "Util.run! ssh, deploy@second.example.com, -t, cd /var/www/example.com/current && bash --login"

    When I run `geordi shell geordi -s5` interactively
      # Answer prompt "Connect to? [1]"
      And I type "1"
    Then the output should contain "> Invalid server number: 5"
    Then the output should contain "Util.run! ssh, deploy@first.example.com, -t, cd /var/www/example.com/current && bash --login"


  Scenario: It understands Capistrano 3 syntax
    Given a file named "config/deploy/geordi.rb" with:
    """
    set :deploy_to, '/var/www/example.com'
    server 'first.example.com', user: 'deploy'
    """

    When I run `geordi shell geordi`
    Then the output should contain "Util.run! ssh, deploy@first.example.com, -t, cd /var/www/example.com/current && bash --login"


  Scenario: It allows multiline capistrano server definitions
    Given a file named "config/deploy/geordi.rb" with:
    """
    set :deploy_to, '/var/www/example.com'
    server 'first.example.com',
      user: 'deploy'
    """

    When I run `geordi shell geordi`
    Then the output should contain "Util.run! ssh, deploy@first.example.com, -t, cd /var/www/example.com/current && bash --login"


  Scenario: It prefers stage settings over general config
    Given a file named "config/deploy.rb" with:
    """
    set :deploy_to, '/var/www/unknown.example.com'
    set :user, 'user'

    server 'www.unknown.example.com'
    """
    And a file named "config/deploy/staging.rb" with:
    """
    set :deploy_to, '/var/www/example.com'

    server 'www.example.com'
    """

    When I run `geordi shell staging`
    Then the output should contain "Util.run! ssh, user@www.example.com, -t, cd /var/www/example.com/current"


  Scenario: It allows whitespaces in the config
    We also add the unset command to check we are still matching the right
    commands and not allow any char at the beginning.

    Given a file named "config/deploy/staging.rb" with:
    """
    unset :user, 'wrong'
     set    :deploy_to,  '/var/www/example.com'
           set  :user,   'user'
        server  'www.example.com'
    """

    When I run `geordi shell staging`
    Then the output should contain "Util.run! ssh, user@www.example.com, -t, cd /var/www/example.com/current"
