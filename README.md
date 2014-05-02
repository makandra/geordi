Geordi
======

Geordi is a collection of command line tools we use in our daily work with
Ruby, Rails and Linux at [makandra](http://makandra.com/).

Installing the *geordi* gem will link several tools into your `/usr/bin` (see
below):

    gem install geordi

Below you can find a list of all included tools.


geordi
------

The base command line utility offering the following commands:

```
$> geordi help
Commands:
  geordi devserver       # Start a development server
  geordi help [COMMAND]  # Describe available commands or one specific command
  geordi migrate         # Migrate all databases
  geordi setup           # Setup a project for the first time
  geordi test            # Run tests
  geordi update          # Bring a project up to date

$> geordi test help
test commands:
  geordi test all             # Run all employed tests
  geordi test cucumber        # Run Cucumber features
  geordi test help [COMMAND]  # Describe subcommands or one specific subcommand
  geordi test rspec           # Run (R)Spec

```

See command help for details (e.g. `geordi test help cucumber`).

You may abbreviate commands by typing only the first letter(s), e.g. `geordi
dev` will boot a development server, `geordi s -t` will setup a project and run
tests afterwards.



apache-site
-----------

Enables the given virtual host in `/etc/apache2/sites-available` and disables all other vhosts:

    apache-site makandra-com

More information at http://makandracards.com/makandra/807-shell-script-to-quickly-switch-apache-sites


b
-

Runs the given command under `bundle exec` if a `Gemfile` is present in your working directory. If no `Gemfile` is present just runs the given command:

    b spec spec/models

More information at http://makandracards.com/makandra/684-automatically-run-bundle-exec-if-required


console-for
-----------

Opens a rails console remotely:

    console-for staging

More information at http://makandracards.com/makandra/1338-console-for-opens-a-rails-console-remotely-on-a-capistrano-deployment-target


cleanup-directory
-----------------

Removes unnecessary files from your project directory:

    cleanup-directory

More information at http://makandracards.com/makandra/951-shell-script-to-clean-up-a-project-directory


deploy-to-production
-------------------

Shows the commits between your `master` and `production` branch, then merges the changes and deploys to the production Capistrano stage:

    deploy-to-production

More information at https://makandracards.com/makandra/7971-shell-script-to-deploy-changes-to-production-and-not-shoot-yourself-in-the-foot


dump-for
--------

Dumps the database on your server for a given [Capistrano multistage](https://github.com/capistrano/capistrano/wiki/2.x-Multistage-Extension) deployment target. Passing the -s option automatically sources the dump ito your development database.

    dump-for production [-s]

More information at http://makandracards.com/makandra/1237-script-to-create-and-copy-a-production-dump-to-your-project-root

     

dumple
------

Stores a timestamped database dump for the given Rails environment in `~/dumps`:

    dumple development

More information at http://makandracards.com/makandra/1008-dump-your-database-with-dumple


load-dump
---------

Loads a database dump (e.g. created with dump-for or dumple) into you database.

    load-dump [path/to/dump]

More information at https://makandracards.com/makandra/8975-geordi-use-load-dump-script-to-source-a-database-dump-into-your-database



gitpt
-----

Shell script to generate a git commit with Pivotal Tracker story ID and title. Run it from your project directory:

    gitpt

This lets you choose from all started, finished and rejected stories in Pivotal Tracker and commit staged changes.
Requires the project's Pivotal Tracker ID(s) to be defined in a `.pt_project_id` file in the project's directory.

More information at https://makandracards.com/makandra/1372-shell-script-to-generate-a-git-commit-with-pivotal-tracker-story-id-and-title


install-gems-remotely
---------------------

Installs all gems in your `Gemfile.lock`, as well as vendored gems, to the given host:

    install-gems-remotely my.server.com

More information at http://makandracards.com/makandra/692-install-a-local-gemfile-on-a-remote-server


power-deploy
------------

Calls the Capistrano tasks `deploy`, `deploy:migrate` and `deploy:restart` on the given [Capistrano multistage](https://github.com/capistrano/capistrano/wiki/2.x-Multistage-Extension) deployment target:

    power-deploy staging

This script is considered legacy and will be removed eventually. You should [fix your deploy scripts](http://makandracards.com/makandra/1176-which-capistrano-hooks-to-use-for-events-to-happen-on-both-cap-deploy-and-cap-deploy-migrations) and then use [cap deploy:migrations](http://makandracards.com/makandra/1000-deploy-and-migrate-with-a-single-capistrano-command).


power-rake
----------

Runs the given rake task in each Rails environment in `development`, `test`, `cucumber`, `performance`, if existing:

    power-rake db:migrate

More information at http://makandracards.com/makandra/737-run-a-rake-task-in-all-environments


remove-executable-flags
-----------------------

Recursively removes executable flags from files in the working directory that probably shouldn't have them (like Ruby, HTML, CSS, image, Rake and similar files).

    remove-executable-flags
    
More information at http://makandracards.com/makandra/659-recursively-remove-unnecessary-execute-flags


setup-firefox-for-selenium
--------------------------

Helps you create an frozen version of Firefox, so your Selenium tests will no longer break whenever Firefox updates:

    setup-firefox-for-selenium

More information at http://makandracards.com/makandra/1575-how-to-install-a-frozen-version-of-firefox-for-your-selenium-tests


shell-for
---------

Opens an SSH shell on the given [Capistrano multistage](https://github.com/capistrano/capistrano/wiki/2.x-Multistage-Extension) deployment target:

    shell-for production

Now it can also be called with any command to be remotely executed before loading the bash. `--no-bash` skips the bash.

    shell-for staging --no-bash top

More information at http://makandracards.com/makandra/1209-script-to-open-an-ssh-shell-to-a-capistrano-deployment-target
