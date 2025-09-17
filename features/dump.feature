Feature: The dump command

  Most aspects of connection to a server are tested in shell feature.

  Scenario: Creating a dump of the development database
    When I run `geordi dump`
    Then the output should contain "Util.run! dumple development"
      And the output should contain "Successfully dumped the development database"
      And the output should not contain "Clean up"


  Scenario: Creating a dump of the development database with multiple databases
    When I run `geordi dump -d primary`
    Then the output should contain "Util.run! dumple development primary"
      And the output should contain "Successfully dumped the primary development database"


  Scenario: Creating a dump of a remote database
    Given a file named "Capfile" with "Capfile exists"
    And a file named "config/deploy.rb" with "deploy.rb exists"
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
      And the output should contain "Util.run! ssh, user@www.example.com, -t, cd /var/www/example.com/current && bash --login -c 'dumple staging --for_download'"
      And the output should contain "> Downloading remote dump to tmp/staging.dump"
      # Omitting the absolute path in this regex (.*)
      And the output should match:
      """
      Util\.run! scp -C user@www\.example\.com:~\/dumps\/dump_for_download.dump .*?\/tmp\/aruba\/tmp\/staging.dump
      """
      And the output should contain "> Dumped the staging database to tmp/staging.dump"


  Scenario: Creating a dump of a remote database and loading it locally
    Given a file named "Capfile" with "Capfile exists"
    And a file named "config/deploy.rb" with "deploy.rb exists"
    And a file named "config/deploy/staging.rb" with:
    """
    set :rails_env, 'staging'
    set :deploy_to, '/var/www/example.com'
    set :user, 'user'

    server 'www.example.com'
    """
    And a file named "config/database.yml" with:
    """
    development:
      database: test
      adapter: postgresql
    """

    When I run `geordi dump staging --load`
    Then the output should contain "# Dumping the database of staging"
      And the output should contain "Util.run! ssh, user@www.example.com, -t, cd /var/www/example.com/current && bash --login -c 'dumple staging --for_download'"
      And the output should contain "> Dumped the staging database to tmp/staging.dump"

      # Loading the dump
      And the output should contain "Sourcing dump into the test db"
      And the output should contain "Dump file removed"
      And the output should contain "Your test database has now the data of staging."


  Scenario: Creating a dump of one of multiple remote databases
    Given a file named "Capfile" with "Capfile exists"
    And a file named "config/deploy.rb" with "deploy.rb exists"
    And a file named "config/deploy/staging.rb" with:
    """
    set :rails_env, 'staging'
    set :deploy_to, '/var/www/example.com'
    set :user, 'user'

    server 'www.example.com'
    """

    When I run `geordi dump staging --database primary`
    Then the output should contain "# Dumping the database of staging (primary database)"
      And the output should contain "Util.run! ssh, user@www.example.com, -t, cd /var/www/example.com/current && bash --login -c 'dumple staging primary --for_download'"
      And the output should contain "> Dumped the primary staging database to tmp/staging.dump"


  Scenario: Creating a dump of one of multiple remote databases and loading it locally
    Given a file named "Capfile" with "Capfile exists"
    And a file named "config/deploy.rb" with "deploy.rb exists"
    And a file named "config/deploy/staging.rb" with:
    """
    set :rails_env, 'staging'
    set :deploy_to, '/var/www/example.com'
    set :user, 'user'

    server 'www.example.com'
    """
    And a file named "config/database.yml" with:
    """
    development:
      primary:
        database: test
        adapter: postgresql
    """

    When I run `geordi dump staging --database primary --load`
    Then the output should contain "# Dumping the database of staging (primary database)"
      And the output should contain "Util.run! ssh, user@www.example.com, -t, cd /var/www/example.com/current && bash --login -c 'dumple staging primary --for_download'"
      And the output should contain "> Dumped the primary staging database to tmp/staging.dump"

      # Loading the dump
      And the output should contain "Sourcing dump into the test db"
      And the output should contain "Dump file removed"
      And the output should contain "Your test database has now the data of staging (primary database)."


  Scenario: Sourcing a dump with mysql
    Given a file named "tmp/production.dump" with "some content"
    And a file named "config/database.yml" with:
      """
      development:
        database: test
        adapter: mysql
      """

    When I run `geordi dump -l tmp/production.dump`
    Then the output should contain "Sourcing dump into the test db"
      And the output should contain "Source file: tmp/production.dump"
      And the output should contain "Util.run! mysql --silent --default-character-set=utf8 test < tmp/production.dump"
      And the output should contain "Your test database has now the data of tmp/production.dump."
    But the output should not contain "Dump file removed"
      And the output should not contain "Util.run! rm"


  Scenario: Sourcing a dump with postgres
    Given a file named "tmp/production.dump" with "some content"
      And a file named "config/database.yml" with:
      """
      development:
        database: test
        adapter: postgresql
        username: db_user
        host: db_host
      """

    When I run `geordi dump -l tmp/production.dump`
    Then the output should contain "Sourcing dump into the test db"
      And the output should contain "Source file: tmp/production.dump"
      And the output should contain "Util.run! dropdb --if-exists --username=db_user --host=db_host test && createdb --username=db_user --host=db_host test && pg_restore --no-owner --no-acl --username=db_user --host=db_host --dbname=test tmp/production.dump"
      And the output should contain "Your test database has now the data of tmp/production.dump."
    But the output should not contain "Dump file removed"
      And the output should not contain "Util.run! rm"


  Scenario: Sourcing a dump into one of multiple databases:
    Given a file named "tmp/production.dump" with "some content"
      And a file named "config/database.yml" with:
      """
      development:
        primary:
          database: test-primary
          adapter: postgresql
        other:
          database: test-other
          adapter: postgresql
      """

      When I run `geordi dump -l tmp/production.dump -d other`
      Then the output should contain "Sourcing dump into the test-other db"
        And the output should contain "Source file: tmp/production.dump"
        And the output should contain "Util.run! dropdb --if-exists test-other && createdb test-other && pg_restore --no-owner --no-acl --dbname=test-other tmp/production.dump"
      But the output should not contain "Sourcing dump into the test-primary db"


  Scenario: Sourcing a dump into one of multiple databases without specifying a db
    Given a file named "tmp/production.dump" with "some content"
      And a file named "config/database.yml" with:
      """
      development:
        other:
          database: test-other
          adapter: postgresql
        primary:
          database: test-primary
          adapter: postgresql
      """
      When I run `geordi dump -l tmp/production.dump`
      Then the output should contain "Sourcing dump into the test-primary db"
        And the output should contain "Source file: tmp/production.dump"
        And the output should contain "Util.run! dropdb --if-exists test-primary && createdb test-primary && pg_restore --no-owner --no-acl --dbname=test-primary tmp/production.dump"
      But the output should not contain "Sourcing dump into the test-other db"


  Scenario: Enforcing compression
    When I run `geordi dump --compress`
    Then the output should contain "Util.run! dumple development --compress"
      And the output should contain "Successfully dumped the development database"


  Scenario: Setting a custom compression algorithm
    When I run `geordi dump --compress=zstd:3`
    Then the output should contain "Util.run! dumple development --compress=zstd:3"
    And the output should contain "Successfully dumped the development database"


  Scenario: Setting a custom compression algorithm for a remote target
    Given a file named "Capfile" with "Capfile exists"
    And a file named "config/deploy.rb" with "deploy.rb exists"
    And a file named "config/deploy/staging.rb" with:
    """
    set :rails_env, 'staging'
    set :deploy_to, '/var/www/example.com'
    set :user, 'user'

    server 'www.example.com'
    """

    When I run `geordi dump staging --compress=zstd:3`
    Then the output should contain "Util.run! ssh, user@www.example.com, -t, cd /var/www/example.com/current && bash --login -c 'dumple staging --compress=zstd:3 --for-download'"
      And the output should contain "> Dumped the staging database to tmp/staging.dump"
