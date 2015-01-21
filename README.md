Geordi
======

Geordi is a collection of command line tools we use in our daily work with
Ruby, Rails and Linux at [makandra](http://makandra.com/).

Installing the `geordi` gem will install some binaries (see below):

    gem install geordi


geordi
------

The base command line utility offering the commands below.

You may abbreviate commands by typing only the first letter(s), e.g. `geordi
dev` will boot a development server, `geordi s -t` will setup a project and run
tests afterwards.

Underscores and dashes are equivalent.

### geordi all-targets

Run a capistrano command on all deploy targets

Example: `geordi all-targets deploy`


### geordi apache-site VIRTUAL_HOST

Enable the given virtual host, disabling all others


### geordi cleanup-directory

Remove unneeded files


### geordi commit

Commit using a story titel from Pivotal Tracker


### geordi console [TARGET]

Open a Rails console locally or on a Capistrano deploy target

Open a Rails console on `staging`: `geordi console staging`

Open a local Rails console: `geordi console`


### geordi cucumber [FILES]

Run Cucumber features

Example: `geordi cucumber features/authentication_feature:3`

Runs Cucumber as you want: bundle exec, cucumber_spinner detection,
separate Firefox for Selenium, etc.


### geordi deploy-to-production

[sic]


### geordi devserver

Start a development server


### geordi dump [TARGET]

Handle dumps

When called without arguments, dumps the development database with `dumple`.

    geordi dump

When called with the --load option, sources the specified dump into the
development database.

    geordi dump -l tmp/staging.dump

When called with a capistrano deploy target (e.g. staging), remotely dumps
the specified target's database and downloads it.

    geordi dump staging

When called with a capistrano deploy target and the --load option, sources the
dump into the development database after downloading it.

    geordi dump staging -l


### geordi help [COMMAND]

Describe available commands or one specific command


### geordi migrate

Migrate all databases

Example: `geordi migrate`

If you are using parallel_tests, this runs migrations in your development
environment and rake parallel:prepare afterwards. Otherwise, invokes `geordi rake`
with db:migrate.


### geordi optimize-png

Optimize .png files

Example: `geordi optimize-png`

- Removes color profiles: cHRM, sRGB, gAMA, ICC, etc.
- Eliminates unused colors and reduce bit-depth (if possible)
- May reduce PNG file size lossless

Batch-optimize all *.png in a directory:
  optimize_png directory

Batch-optimize the current directory:
  optimize_png .

Optimize single file:
  optimize_png input.png


#### More info about pngcrush

pngcrush -rem allb -reduce -brute original.png optimized.png
pngcrush -d target-dir/ *.png

-rem allb — remove all extraneous data (Except transparency and gamma; to remove everything except transparency, try -rem alla)
-reduce — eliminate unused colors and reduce bit-depth (If possible)

-brute — attempt all optimization methods (Requires MUCH MORE processing time and may not improve optimization by much)

original.png — the name of the original (unoptimized) PNG file
optimized.png — the name of the new, optimized PNG file
-d target-dir/  — bulk convert into this directory "target-dir"

-rem cHRM -rem sRGB -rem gAMA -rem ICC — remove color profiles by name (shortcut -rem alla)

An article explaining why removing gamma correction
http://hsivonen.iki.fi/png-gamma/


### geordi rake TASK

Run a rake task in all Rails environments


### geordi remove-executable-flags

Remove executable-flags from files that should not be executable


### geordi rspec [FILES]

Run RSpec

Example: `geordi rspec spec/models/user_spec.rb:13`

Runs RSpec as you want: RSpec 1&2 detection, bundle exec, rspec_spinner
detection.


### geordi security-update [step]

Support for performing security updates

Preparation for security update: `geordi security-update`

After performing the update: `geordi security-update finish`


### geordi setup

Setup a project for the first time

Example: `geordi setup`

You check out a repository, cd into its directory and then let `setup` do the
tiring work: bundle install, create database.yml, create databases,
migrate (all if applicable). See options for more.


### geordi setup-firefox-for-selenium VERSION

Install a special firefox for running Selenium tests


### geordi setup-vnc

Setup VNC for running Selenium tests there


### geordi shell TARGET

Open a shell on a Capistrano deploy target


### geordi tests

Run all employed tests


### geordi unit

Run Test::Unit


### geordi update

Bring a project up to date

Example: `geordi update`

Performs: git pull, bundle install (if necessary) and migrate (if applicable).
See options for more.


### geordi version

Print the current version of geordi


### geordi vnc-show

Show the hidden VNC window


### geordi with-firefox-for-selenium COMMAND

Run a command with firefox for selenium set up


### geordi with-rake

Run tests with `rake`




b
---

Runs the given command under `bundle exec` if a `Gemfile` is present in your
working directory. If no `Gemfile` is present just runs the given command:

    b spec spec/models

More information at http://makandracards.com/makandra/684-automatically-run-bundle-exec-if-required


dumple
------

Stores a timestamped database dump for the given Rails environment in `~/dumps`:

    dumple development

More information at http://makandracards.com/makandra/1008-dump-your-database-with-dumple


launchy_browser
---------------

Used by the `geordi cucumber` command. Makes launchy open pages in the user's
browser, as opposed to opening it within the VNC window.


Contributing
============

Copy `lib/geordi/COMMAND_TEMPLATE` to `lib/geordi/commands/your_command` and
edit it to do what you need it to do. Usually, it is hard to automatedly test
Geordi commands, so make sure you've manually tested it.

Don't forget to update this README. The `geordi` section is automatically updated
by running `rake update_readme`.
