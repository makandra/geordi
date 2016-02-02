Feature: The dump command

  Scenario: Creating a dump of the development database
    When I run `geordi dump`
    Then the output should contain "Util.system! dumple development"
      And the output should contain "Successfully dumped the development database"


  Scenario: Creating a dump of a remote database
    Given a file named "Capfile" with "Capfile exists"
    And a file named "config/deploy.rb" with:
    """
    """
    And a file named "config/deploy/staging.rb" with:
    """
    set :rails_env, 'staging'
    set :deploy_to, '/var/www/example.com'
    set :user, 'user'

    server 'www.example.com'
    """

    When I run `geordi dump staging`
    Then the output should contain "# Dumping the database of staging"
      And the output should contain "> Connecting to www.example.com"
      And the output should contain "Util.system! ssh user@www.example.com -t cd /var/www/example.com/current && bash --login -c 'dumple staging --for_download'"
      And the output should contain "> Downloading remote dump to tmp/staging.dump"
      # Omitting the absolute path in this regex (.*)
      And the output should match %r<Util.system! scp user@www.example.com:~/dumps/dump_for_download.dump .*/tmp/aruba/tmp/staging.dump>
      And the output should contain "> Dumped the staging database to tmp/staging.dump"

