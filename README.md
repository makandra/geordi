Geordi
======

Geordi is a collection of command line tools we use in our daily work with
Ruby, Rails and Linux at [makandra](http://makandra.com/).

Installing the `geordi` gem will install some binaries (see below):

    gem install geordi


geordi
------

The base command line utility offering most of the commands.

You may abbreviate commands by typing only the first letter(s), e.g. `geordi
dev` will boot a development server, `geordi s -t` will setup a project and run
tests afterwards. Underscores and dashes are equivalent.

For details on commands, e.g. supported options, run `geordi help <command>`.

### geordi apache-site VIRTUAL_HOST

Enable the given virtual host, disabling all others.


### geordi capistrano COMMAND

Run a capistrano command on all deploy targets.

Example: `geordi capistrano deploy`


### geordi cleanup-directory

Remove unneeded files.


### geordi commit

Commit using a story title from Pivotal Tracker.


### geordi console [TARGET]

Open a Rails console locally or on a Capistrano deploy target.

Open a local Rails console: `geordi console`

Open a Rails console on `staging`: `geordi console staging`


### geordi cucumber [FILES]

Run Cucumber features.

Example: `geordi cucumber features/authentication_feature:3`

Runs Cucumber as you want: with `bundle exec`, `cucumber_spinner` detection,
separate Firefox for Selenium, etc.


### geordi deploy

Guided deployment.


### geordi devserver

Start a development server.


### geordi dump [TARGET]

Handle dumps.

When called without arguments, dumps the development database with `dumple`.

    geordi dump

When called with the `--load` option, sources the specified dump into the
development database.

    geordi dump -l tmp/staging.dump

When called with a capistrano deploy target (e.g. `staging`), remotely dumps
the specified target's database and downloads it to `tmp/`.

    geordi dump staging

When called with a capistrano deploy target and the `--load` option, sources the
dump into the development database after downloading it.

    geordi dump staging -l


### geordi eurest

Open the current Eurest cantina menu.


### geordi help [COMMAND]

Describe available commands or one specific command.


### geordi migrate

Migrate all databases.

Example: `geordi migrate`

If you are using `parallel_tests`, this runs migrations in your development
environment and `rake parallel:prepare` afterwards. Otherwise, invokes `geordi rake`
with `db:migrate`.


### geordi png-optimize

Optimize .png files.

- Removes color profiles: cHRM, sRGB, gAMA, ICC, etc.
- Eliminates unused colors and reduces bit-depth (if possible)
- May reduce PNG file size lossless

Batch-optimize all `*.png` files in a directory:

    geordi png-optimize directory

Batch-optimize the current directory:

    geordi png-optimize .

Optimize a single file:

    geordi png-optimize input.png


### geordi rake TASK

Run a rake task in several Rails environments.

Example: `geordi rake db:migrate`

`TASK` is run in the following Rails environments (if present):

- development
- test
- cucumber


### geordi remove-executable-flags

Remove executable-flags from files that should not be executable.


### geordi rspec [FILES]

Run RSpec.

Example: `geordi rspec spec/models/user_spec.rb:13`

Runs RSpec as you want: with RSpec 1/2 detection, `bundle exec`, rspec_spinner
detection, etc.


### geordi security-update [STEP]

Support for performing security updates.

Preparation for security update: `geordi security-update`

After performing the update: `geordi security-update finish`

Switches branches, pulls, pushes and deploys as required by our workflow. Tells
what it will do before it does it.


### geordi setup

Setup a project for the first time.

Example: `geordi setup`

Check out a repository, cd into its directory. Now let `setup` do the tiring
work: run `bundle install`, create `database.yml`, create databases, migrate
(all if applicable).

After setting up, loads a dump into the development db when called with the
`--dump` option:

    geordi setup -d staging

After setting up, runs all tests when called with the `--test` option:

    geordi setup -t

See `geordi help setup` for details.


### geordi setup-firefox-for-selenium VERSION

Install a special firefox for running Selenium tests.


### geordi setup-vnc

Setup VNC for running Selenium tests there.


### geordi shell TARGET

Open a shell on a Capistrano deploy target.

Example: `geordi shell production`

Lets you select the server to connect to when called with `--select-server`:

    geordi shell production -s


### geordi tests

Run all employed tests.


### geordi unit

Run Test::Unit.


### geordi update

Bring a project up to date.

Example: `geordi update`

Performs: `git pull`, `bundle install` (if necessary) and migrates (if applicable).

After updating, loads a dump into the development db when called with the
`--dump` option:

    geordi update -d staging

After updating, runs all tests when called with the `--test` option:

    geordi update -t

See `geordi help update` for details.


### geordi version

Print the current version of geordi.


### geordi vnc-show

Show the hidden VNC window.


### geordi with-firefox-for-selenium COMMAND

Run a command with firefox for selenium set up.

Example: `geordi with-firefox-for-selenium b cucumber`

Useful when you need Firefox for Selenium, but can't use the `geordi cucumber`
command.


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

Don't forget to update this README. The whole `geordi` section is auto-generated
by `rake update_readme`.
