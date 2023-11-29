Feature: The console command
  Most aspects of connection to a server are tested in shell feature.

  Scenario: Opening a local Rails console with an irb version < 1.2.0 and preconfigured irb flags from the global settings
    Given the irb version is "1.1.0"
      And a file named "tmp/global_settings.yml" with "irb_flags: --foo --baz"
    When I run `geordi console`
    Then the output should contain "# Opening a local Rails console"
      And the output should contain "Util.run! (exec) bundle exec rails console -e development -- --foo --baz"
      But the output should not contain "nomultiline"


  Scenario: Opening a local Rails console with an Ruby version >= 3.0
    Given the Ruby version is "3.0"
    When I run `geordi console`
    Then the output should contain "# Opening a local Rails console"
      And the output should contain "Util.run! (exec) bundle exec rails console -e development"
      But the output should not contain "nomultiline"


  Scenario: Opening a local Rails console with an irb version >= 1.2.0 and Ruby version < 3.0
    Given the irb version is "1.2.0"
      And the Ruby version is "2.9"
    When I run `geordi console`
    Then the output should contain "# Opening a local Rails console"
      And the output should contain "Util.run! (exec) bundle exec rails console -e development -- --nomultiline"
      And the output should contain "Using --nomultiline switch for faster pasting"


  Scenario: Opening a remote Rails console with an irb version >= 1.2.0 and Ruby version < 3.0
    Given the irb version is "1.2.0"
      And the Ruby version is "2.9"
      And a file named "Capfile" with "Capfile exists"
      And a file named "config/deploy.rb" with "deploy file exists"
      And a file named "config/deploy/staging.rb" with:
      """
      set :rails_env, 'staging'
      set :deploy_to, '/var/www/example.com'
      set :user, 'user'
      server 'www.example.com'
      """
    When I run `geordi console staging`
    Then the output should contain "# Opening a Rails console on staging"
      And the output should contain "Util.run! ssh, user@www.example.com, -t, cd /var/www/example.com/current && bash --login -c 'bundle exec rails console -e staging -- --nomultiline"
      And the output should contain "Using --nomultiline switch for faster pasting"


Scenario: Opening a remote Rails console with an irb version >= 1.2.0, a Ruby version < 3.0 and preconfigured irb flags from the global settings
  Given the irb version is "1.2.0"
    And the Ruby version is "2.9"
    And a file named "tmp/global_settings.yml" with "irb_flags: --foo --baz"
    And a file named "Capfile" with "Capfile exists"
    And a file named "config/deploy.rb" with "deploy file exists"
    And a file named "config/deploy/staging.rb" with:
    """
    set :rails_env, 'staging'
    set :deploy_to, '/var/www/example.com'
    set :user, 'user'
    server 'www.example.com'
    """
  When I run `geordi console staging`
  Then the output should contain "# Opening a Rails console on staging"
    And the output should contain "Util.run! ssh, user@www.example.com, -t, cd /var/www/example.com/current && bash --login -c 'bundle exec rails console -e staging -- --nomultiline --foo --baz"
