Geordi
======

Geordi is a collection of command line tools we use in our daily work with
Ruby, Rails and Linux at [makandra](http://makandra.com/).

Installing the *geordi* gem will link some binaries into your `/usr/bin` (see
below):

    gem install geordi

Below you can find a list of all included binaries, of which `geordi` contains
most of the commands.


geordi
------

The base command line utility offering the following commands:

```
$> geordi help
Commands:
  geordi all_targets                 # Run a capistrano command on all deploy targets
  geordi apache_site                 # ?
  geordi cleanup_directory           # Remove unneeded files
  geordi commit                      # Commit using a story titel from Pivotal Tracker
  geordi console TARGET              # Open a Rails console on a Capistrano deploy target
  geordi cucumber [FILES]            # Run Cucumber features
  geordi deploy_to_production        # Deploy to production
  geordi devserver                   # Start a development server
  geordi dump [TARGET]               # Handle dumps
  geordi help [COMMAND]              # Describe available commands or one specific command
  geordi launchy_browser             # ?
  geordi migrate                     # Migrate all databases
  geordi optimize_png                # Optimize .png files
  geordi rake                        # Run rake in all Rails environments
  geordi remove_executable_flags     # Remove executable-flags from files that should not be executable
  geordi rspec [FILES]               # Run RSpec
  geordi setup                       # Setup a project for the first time
  geordi setup_firefox_for_selenium  # [sic]
  geordi setup_vnc                   # ?
  geordi shell TARGET                # Open a shell on a Capistrano deploy target
  geordi test                        # Run all employed tests
  geordi test_unit                   # Run Test::Unit
  geordi update                      # Bring a project up to date
  geordi version                     # Print the current version of geordi
  geordi vnc_show                    # Show the hidden VNC window
  geordi with_rake                   # Run tests with `rake`
```

See command help for details (e.g. `geordi help cucumber`).

You may abbreviate commands by typing only the first letter(s), e.g. `geordi
dev` will boot a development server, `geordi s -t` will setup a project and run
tests afterwards.

b
---

Runs the given command under `bundle exec` if a `Gemfile` is present in your working directory. If no `Gemfile` is present just runs the given command:

    b spec spec/models

More information at http://makandracards.com/makandra/684-automatically-run-bundle-exec-if-required


dumple
------

Stores a timestamped database dump for the given Rails environment in `~/dumps`:

    dumple development

More information at http://makandracards.com/makandra/1008-dump-your-database-with-dumple
