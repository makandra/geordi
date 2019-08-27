Geordi [![Build Status](https://travis-ci.org/makandra/geordi.svg?branch=master)](https://travis-ci.org/makandra/geordi)
======

Geordi is a collection of command line tools we use in our daily work with
Ruby, Rails and Linux at [makandra](http://makandra.com/).

Installation:

    gem install geordi


`geordi`
--------

The `geordi` binary holds most of the utility commands. For the few other
binaries, see the bottom of this file.

You may abbreviate commands by typing only their first letters, e.g. `geordi
con` will boot a development console, `geordi set -t` will setup a project and
run tests afterwards.

For details on commands, e.g. supported options, you may always run
`geordi help <command>`.

### `geordi apache-site VIRTUAL_HOST`

Enable the given virtual host, disabling all others.


### `geordi capistrano COMMAND`

Run a capistrano command on all deploy targets.

Example: `geordi capistrano deploy`


### `geordi clean`

Remove unneeded files from the current directory.


### `geordi commit`

Commit using a story title from Pivotal Tracker.

Example: `geordi commit`

On the first execution we ask for your Pivotal Tracker API token. It will be
stored in `~/.gitpt`.


### `geordi console [TARGET]`

Open a Rails console locally or on a Capistrano deploy target.

Open a local Rails console: `geordi console`

Open a Rails console on `staging`: `geordi console staging`


### `geordi cucumber [FILES and OPTIONS]`

Run Cucumber features.

Example: `geordi cucumber features/authentication_feature:3`

Runs Cucumber as you want: with `bundle exec`, using parallel tests, with
a VNC session holding Selenium test browsers, support for using a dedicated
testing firefox and beta support for rerunning failed scenarios.

- *@solo:* Generally, features are run in parallel. However, scenarios tagged
with @solo are excluded and will be run sequentially, _after_ the parallel run.

- *Debugging:* Sometimes, the dot-printing Cucumber formatter does not show
errors. In case a feature fails without a message, try running it with `--debug`
or `-d`.

- *Options:* Any unknown option will be passed through to Cucumber,
e.g. `--format pretty`.


### `geordi delete_dumps [DIRECTORY]`

Delete database dump files (*.dump).

Example: `geordi delete_dumps` or `geordi delete_dumps ~/tmp/dumps`

Recursively search for files ending in `*.dump` and offer to delete those. When
no argument is given, two default directories are searched for dump files: the
current working directory and `~/dumps` (for dumps created with geordi).

Geordi will ask for confirmation before actually deleting files.


### `geordi deploy [STAGE]`

Guided deployment across branches.

Example: `geordi deploy` or `geordi deploy p[roduction]`

Merge, push and deploy with a single command! There are several scenarios where
this command comes in handy:

1) *Production deploy:* From the master branch, run `geordi deploy production`.
   This will merge `master` to `production`, push and deploy to production.

2) *Feature branch deploy:* From a feature branch, run `geordi deploy staging`.
   This will merge the feature branch to `master`, push and deploy to staging.

3) *Simple deploy:* If the source branch matches the target branch, merging will
   be skipped.

Calling the command without arguments will infer the target stage from the
current branch and fall back to master/staging.

Finds available Capistrano stages by their prefix, e.g. `geordi deploy p` will
deploy production, `geordi deploy mak` will deploy a `makandra` stage if there
is a file config/deploy/makandra.rb.

When your project is running Capistrano 3, deployment will use `cap deploy`
instead of `cap deploy:migrations`. You can force using `deploy` by passing the
-M option: `geordi deploy -M staging`.


### `geordi drop-databases`

Interactively delete local databases.

Example: `geordi drop_databases`

Check both MySQL/MariaDB and Postgres on the machine running geordi for databases
and offer to delete them. Excluded are databases that are whitelisted. This comes
in handy when you're keeping your currently active projects in the whitelist files
and perform regular housekeeping with Geordi.

When called with `-P` or `-M` options, only handles Postgres resp. MySQL/MariaDB.

When called with `--postgres <port or local socket>` or `--mysql <port or local socket>`,
will instruct the underlying management commands to use those connection methods
instead of the defaults. This is useful when running multiple installations.

Geordi will ask for confirmation before actually dropping databases and will
offer to edit the whitelist instead.


### `geordi dump [TARGET]`

Handle dumps (see `geordi help dump` for details).

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


### `geordi firefox COMMAND`

Run a command with VNC and test browser set up (alias: chrome).

Example: `geordi firefox b cucumber` or `geordi firefox --setup 24.0`

Useful when you need Firefox for Selenium or the VNC set up, but can't use the
`geordi cucumber` command.

*Install* a special Firefox by calling with `--setup <version>`.

This command is aliased `chrome` for users running Selenium in Chrome.


### `geordi help [COMMAND]`

Describe available commands or one specific command.


### `geordi migrate`

Migrate all databases.

Example: `geordi migrate`

If you are using `parallel_tests`, this runs migrations in your development
environment and `rake parallel:prepare` afterwards. Otherwise, invokes `geordi rake`
with `db:migrate`.


### `geordi png-optimize PATH`

Optimize .png files.

Example: `geordi png-optimize some/directory`

- Removes color profiles: cHRM, sRGB, gAMA, ICC, etc.
- Eliminates unused colors and reduces bit-depth (if possible)
- May reduce PNG file size lossless


### `geordi rake TASK`

Run a rake task in several Rails environments.

Example: `geordi rake db:migrate`

`TASK` is run in the following Rails environments (if present):

- development
- test
- cucumber


### `geordi remove-executable-flags`

Remove executable-flags from files that should not be executable.


### `geordi rspec [FILES]`

Run RSpec.

Example: `geordi rspec spec/models/user_spec.rb:13`

Runs RSpec as you want: with RSpec 1/2 detection, `bundle exec`, rspec_spinner
detection, etc.


### `geordi security-update [STEP]`

Support for performing security updates.

Preparation for security update: `geordi security-update`

After performing the update: `geordi security-update finish`

Switches branches, pulls, pushes and deploys as required by our workflow. Tells
what it will do before it does it.


### `geordi server [PORT]`

Start a development server.


### `geordi setup`

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


### `geordi shell TARGET`

Open a shell on a Capistrano deploy target.

Example: `geordi shell production`

Lets you select the server to connect to when called with `--select-server`:

    geordi shell production -s


### `geordi tests`

Run all employed tests.


### `geordi unit`

Run Test::Unit.


### `geordi update`

Bring a project up to date.

Example: `geordi update`

Performs: `git pull`, `bundle install` (if necessary) and migrates (if applicable).

After updating, loads a dump into the development db when called with the
`--dump` option:

    geordi update -d staging

After updating, runs all tests when called with the `--test` option:

    geordi update -t

See `geordi help update` for details.


### `geordi version`

Print the current version of geordi.


### `geordi vnc`

Show the hidden VNC window.

Example: `geordi vnc` or `geordi vnc --setup`

Launch a VNC session to the hidden screen where `geordi cucumber` runs Selenium
tests.

When called with `--setup`, will guide through the setup of VNC.


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
Geordi commands, so make sure you've manually tested it. You can do so by
calling your local geordi like so (adjust paths to your needs):

    # @option -I: add directory to load path
    ruby -I ../geordi/lib ../geordi/bin/geordi <command>

Don't forget to update this README. The whole `geordi` section is auto-generated
by `rake readme`. Also remember to add your changes to the CHANGELOG.

Geordi is (partially) tested with Cucumber and Aruba. Run `bundle exec rake` to test the gem against you current Ruby
version. The `travis.yml` contains all Ruby versions the gem is and needs to be tested with.
