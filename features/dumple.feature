Feature: Creating Rails database dumps with the "dumple" script

  The --for-download option generates a deterministic file name.

  Scenario: Execution outside of a Rails application
    When I run `dumple development`
    Then the output should contain "Call me from inside a Rails project"


  Scenario: Creating a dump of the local development database
    Given a file named "config/database.yml" with:
    """
    development:
      adapter: mysql
      database: geordi_development
    """
    And a mocked home directory
    And a file named "dumps/dump_for_download.dump" with:
    """
    Since dumple won't actually dump in tests, we prepare the dump file in advance.
    """

    When I run `dumple development --for-download`
    Then the output should match /Dumping database for "development" environment/
      And the output should contain "> Dumped to /home/"
      And the output should contain "/geordi/tmp/aruba/dumps/dump_for_download.dump (0 KB)"


  Scenario: Dumping a MySQL database
    Given a file named "config/database.yml" with:
    """
    development:
      adapter: mysql
      username: user
      password: password
    """
    And a mocked home directory

    When I run `dumple development --for-download`
    Then the output should match %r<system mysqldump -u"user" -p"password"  -r /home/.*/aruba/dumps/dump_for_download.dump --single-transaction --quick -hlocalhost>


  Scenario: Dumping a PostgreSQL database
    Given a file named "config/database.yml" with:
    """
    development:
      adapter: postgres
      username: user
      password: password
    """
    And a mocked home directory

    When I run `dumple development --for-download`
    Then the output should match %r<system PGPASSWORD="password" pg_dump  --clean --format=custom --file=/home/.*/aruba/dumps/dump_for_download.dump --username="user">


  Scenario: Dumping with multiple databases (one is primary)
    Given a file named "config/database.yml" with:
    """
    development:
      migration:
        adapter: mysql
        database: geordi_migration
      primary:
        adapter: postgres
        database: geordi_development
    """

    When I run `dumple development`
    Then the output should contain "> Multiple databases detected. Defaulting to primary database."
      And the output should match /Dumping database for "development" environment/
      And the output should contain "pg_dump geordi_development"


  Scenario: Dumping with multiple databases (none is primary)
    Given a file named "config/database.yml" with:
    """
    development:
      app:
        adapter: postgres
        database: geordi_development
      migration:
        adapter: mysql
        database: geordi_migration
    """

    When I run `dumple development`
    Then the output should contain "> Multiple databases detected. Defaulting to first entry (app)."
    And the output should match /Dumping database for "development" environment/
    And the output should contain "pg_dump geordi_development"


  Scenario: Dumping one of multiple databases
    Given a file named "config/database.yml" with:
    """
    development:
      app:
        adapter: mysql
        database: geordi_development
      migration:
        adapter: postgres
        database: geordi_migration
    """

    When I run `dumple development migration`
    Then the output should match /Dumping migration database for "development" environment/
      And the output should contain "pg_dump geordi_migration"


  Scenario: Dumping a non-existing database in a multi-db setup
    Given a file named "config/database.yml" with:
    """
    development:
      app:
        adapter: mysql
        database: geordi_development
      migration:
        adapter: postgres
        database: geordi_migration
    """

    When I run `dumple development nonexistent`
    Then the output should match /Unknown development database "nonexistent"/


  Scenario: Requesting a sub-database in a single-db setup
    Given a file named "config/database.yml" with:
    """
    development:
      adapter: mysql
      database: geordi_development
    """

    When I run `dumple development sub`
    Then the output should match /Could not select "sub" database in a single-db environment/


  Scenario: Instructing MySQL to compress the dump
    Given a file named "config/database.yml" with:
    """
    development:
      adapter: mysql
      database: geordi_development
    """
    And a mocked home directory
    And a file named "dumps/dump_for_download.dump.gz" with:
    """
    Since dumple won't actually dump in tests, we prepare the dump file in advance.
    """

    When I run `dumple development --for-download --compress`
    Then the output should match /Dumping database for "development" environment/
      And the output should contain "> Compressing the dump ..."
      And the output should contain "system gzip"
      And the output should contain "> Dumped to /home/"
      And the output should contain "/geordi/tmp/aruba/dumps/dump_for_download.dump.gz (0 KB)"


  Scenario: Instructing MySQL to compress the dump with a custom compression algorithm shows a warning
    Given a file named "config/database.yml" with:
    """
    development:
      adapter: mysql
      database: geordi_development
    """
    And a mocked home directory
    And a file named "dumps/dump_for_download.dump.gz" with:
    """
    Since dumple won't actually dump in tests, we prepare the dump file in advance.
    """

    When I run `dumple development --for-download --compress=zstd:3`
    Then the output should match /Dumping database for "development" environment/
      And the output should contain "> Cannot compress a MySQL dump with zstd:3, falling back to gzip."
      And the output should contain "> Compressing the dump ..."
      And the output should contain "system gzip"
      And the output should contain "> Dumped to /home/"
      And the output should contain "/geordi/tmp/aruba/dumps/dump_for_download.dump.gz (0 KB)"


  Scenario: Setting a custom compression algorithm for PostgreSQL
    Given a file named "config/database.yml" with:
    """
    development:
      adapter: postgres
      username: user
      password: password
    """
    And a mocked home directory

    When I run `dumple development --for-download --compress=zstd:3`
    Then the output should match %r<system PGPASSWORD="password" pg_dump  --clean --format=custom --compress=zstd:3 --file=/home/.*/aruba/dumps/dump_for_download.dump --username="user">
