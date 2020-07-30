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

You can always run `geordi help <command>` to quickly look up command help.

### `geordi apache-site VIRTUAL_HOST`
Enable the given virtual host, disabling all others.


### `geordi capistrano COMMAND`
Run a capistrano command on all deploy targets.

Example: `geordi capistrano deploy`


### `geordi chromedriver-update`
Update the chromedriver.

Example: `geordi chromedriver_update`

This command will find and install the matching chromedriver for the currently
installed Chrome.


### `geordi clean`
Remove unneeded files from the current directory.


### `geordi commit`
Commit using a story title from Pivotal Tracker.

Example: `geordi commit`

Any extra arguments are forwarded to `git commit -m <message>`.

On the first execution we ask for your Pivotal Tracker API token. It will be
stored in `~/.config/geordi/global.yml`.


### `geordi console [TARGET]`
Open a Rails console locally or on a Capistrano deploy target.

Local (development): `geordi console`

Remote: `geordi console staging`

Selecting the server: `geordi console staging -s` shows a menu with all available
servers. When passed a number, directly connects to the selected server.

**Options**
- `-s, [--select-server=[SERVER_NUMBER]]`: Select a server to connect to


### `geordi cucumber [FILES and OPTIONS]`
Run Cucumber features.

Example: `geordi cucumber features/authentication_feature:3`

Runs Cucumber with `bundle exec`, using parallel tests, with a VNC session
holding Selenium test browsers, support for using a dedicated testing browser
and beta support for re-running failed scenarios.

- *@solo:* Generally, features are run in parallel. However, scenarios tagged
with @solo are excluded from the parallel run and executed sequentially instead.

- *Debugging:* In some cases, the dot-printing Cucumber formatter swallows
errors. In case a feature fails without an error message, try running it with
`--debug` or `-d`.

- *Options:* Any unknown option will be passed through to Cucumber,
e.g. `--format=pretty`. Make sure to connect option and value with an equals
sign, i.e. have each option a contiguous string.

- *VNC:* By default, test browsers will run in a VNC session. When using a
headless test browser anyway, you can disable VNC by setting `use_vnc: false`
in `.geordi.yml` in the project root.

**Options**
- `-m, [--modified], [--no-modified]`: Run all modified features
- `-c, [--containing=STRING]`: Run all features that contain STRING
- `-v, [--verbose], [--no-verbose]`: Show the test run command
- `-d, [--debug], [--no-debug]`: Run Cucumber with `-f pretty -b`, which helps hunting down bugs
- `-r, [--rerun=N]`: Rerun features up to N times while failing


### `geordi delete-dumps [DIRECTORY]`
Delete database dump files (*.dump).

Example: `geordi delete_dumps` or `geordi delete_dumps ~/tmp/dumps`

Recursively search for files ending in `*.dump` and offer to delete those. When
no argument is given, two default directories are searched for dump files: the
current working directory and `~/dumps` (for dumps created with geordi).

Geordi will ask for confirmation before actually deleting files.


### `geordi deploy [STAGE]`
Guided deployment across branches.

Example: `geordi deploy` or `geordi deploy p[roduction]` or `geordi deploy --current-branch`

Merge, push and deploy with a single command! **It always tells what it will do
before it does it.** There are different scenarios where this command is handy:

- *Production deploy:* From the master branch, run `geordi deploy production`.
  This will merge `master` to `production`, push and deploy to production.

- *Feature branch deploy:* From a feature branch, run `geordi deploy staging`.
  This will merge the feature branch to `master`, push and deploy to staging.

  To deploy a feature branch directly without merging, run
  `geordi deploy --current-branch`. This feature depends on the environment
  variable `DEPLOY_BRANCH` to be picked up in the respective deploy file.

- *Simple deploy:* If the source branch matches the target branch, merging will
  be skipped.

Calling the command without arguments will infer the target stage from the
current branch and fall back to master/staging.

Finds available Capistrano stages by their prefix, e.g. `geordi deploy p` will
deploy production, `geordi deploy mak` will deploy a `makandra` stage if there
is a file config/deploy/makandra.rb.

When your project is running Capistrano 3, deployment will use `cap deploy`
instead of `cap deploy:migrations`. You can force using `deploy` by passing the
-M option: `geordi deploy -M staging`.

**Options**
- `-M, [--no-migrations], [--no-no-migrations]`: Run cap deploy instead of cap deploy:migrations
- `-c, [--current-branch], [--no-current-branch]`: Set DEPLOY_BRANCH to the current branch during deploy


### `geordi drop-databases`
Interactively delete local databases.

Example: `geordi drop_databases`

Check both MySQL/MariaDB and Postgres on the machine running geordi for databases
and offer to delete them. Excluded are databases that are whitelisted. This comes
in handy when you're keeping your currently active projects in the whitelist files
and perform regular housekeeping with Geordi.

Geordi will ask for confirmation before actually dropping databases and will
offer to edit the whitelist instead.

**Options**
- `-P, [--postgres-only], [--no-postgres-only]`: Only clean Postgres
- `-M, [--mysql-only], [--no-mysql-only]`: Only clean MySQL/MariaDB
- `[--postgres=PORT_OR_SOCKET]`: Use Postgres port or socket
- `[--mysql=PORT_OR_SOCKET]`: Use MySQL/MariaDB port or socket


### `geordi dump [TARGET]`
Handle (remote) database dumps.

`geordi dump` (without arguments) dumps the development database with `dumple`.

`geordi dump -l tmp/staging.dump` (with the `--load` option) sources the
specified dump file into the development database.

`geordi dump staging` (with a Capistrano deploy target) remotely dumps the
specified target's database and downloads it to `tmp/`.

`geordi dump staging -l` (with a Capistrano deploy target and the `--load`
option) sources the dump into the development database after downloading it.

**Options**
- `-l, [--load=[DUMP_FILE]]`: Load a dump


### `geordi firefox COMMAND`
Run a command with VNC and test browser set up (alias: chrome).

Example: `geordi firefox b cucumber` or `geordi firefox --setup 24.0`

Useful when you need Firefox for Selenium or the VNC set up, but can't use the
`geordi cucumber` command. This command is aliased `chrome` for users running
Selenium in Chrome.

**Options**
- `[--setup=FIREFOX_VERSION]`: Install a special test runner Firefox with the given version


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

Runs RSpec with RSpec 1/2 support, parallel_tests detection and `bundle exec`.


### `geordi security-update [STEP]`
Support for performing security updates.

Preparation for security update: `geordi security-update`. Checks out production
and pulls.

After performing the update: `geordi security-update finish`. Switches branches,
pulls, pushes and deploys as required by our workflow.

This command tells what it will do before it does it. In detail:

1. Ask user if tests are green

2. Push production

3. Check out master and pull

4. Merge production and push in master

5. Deploy staging, if there is a staging environment

6. Ask user if deployment log is okay and staging application is still running

7. Deploy other stages

8. Ask user if deployment log is okay and application is still running on all stages

9. Inform user about the next (manual) steps


### `geordi server [PORT]`
Start a development server.

**Options**
- `-p, [--port=PORT]`: Choose a port
- `-P, [--public], [--no-public]`: Make the server accessible from the local network


### `geordi setup`
Setup a project for the first time.

Example: `geordi setup`

Check out a repository and cd into its directory. Then let `setup` do the tiring
work: run `bundle install`, create `database.yml`, create databases, migrate
(all if applicable).

If a local bin/setup file is found, Geordi skips its routine and runs bin/setup
instead.

**Options**
- `-d, [--dump=TARGET]`: After setup, dump the TARGET db and source it into the development db
- `-t, [--test], [--no-test]`: After setup, run tests


### `geordi shell TARGET`
Open a shell on a Capistrano deploy target.

Example: `geordi shell production`

Selecting the server: `geordi shell staging -s` shows a menu with all available
servers. When passed a number, directly connects to the selected server.

**Options**
- `-s, [--select-server=[SERVER_NUMBER]]`: Select a server to connect to


### `geordi tests`
Run all employed tests.


### `geordi unit`
Run Test::Unit.


### `geordi update`
Bring a project up to date.

Example: `geordi update`

Performs: `git pull`, `bundle install` (if necessary) and migrates (if applicable).

**Options**
- `-d, [--dump=TARGET]`: After updating, dump the TARGET db and source it into the development db
- `-t, [--test], [--no-test]`: After updating, run tests


### `geordi version`
Print the current version of geordi.


### `geordi vnc`
Show the hidden VNC window.

Example: `geordi vnc` or `geordi vnc --setup`

Launch a VNC session to the hidden screen where `geordi cucumber` runs Selenium
tests.

**Options**
- `[--setup], [--no-setup]`: Guide through the setup of VNC

b
---

Runs the given command under `bundle exec` if a `Gemfile` is present in your
working directory. If no `Gemfile` is present just runs the given command:

    b spec spec/models

See http://makandracards.com/makandra/684-automatically-run-bundle-exec-if-required


dumple
------

Stores a timestamped database dump for the given Rails environment in `~/dumps`:

    dumple development

See http://makandracards.com/makandra/1008-dump-your-database-with-dumple


launchy_browser
---------------

Used by the `geordi cucumber` command. Makes launchy open pages in the user's
browser, as opposed to opening it within the VNC window.


Contributing
============

* Run the tests for the oldest supported ruby version with `bundle exec rake`. Ensure that all other ruby versions in the `travis.yml` pass as well after pushing your feature branch and triggering the travis build.
* Update this `README`. The whole `geordi` section is auto-generated from command
  descriptions when running `rake readme`.
* Document your changes in the `CHANGELOG.md` file.


Adding a new command
---------------

Copy `lib/geordi/COMMAND_TEMPLATE` to `lib/geordi/commands/your_command` and
edit it to do what you need it to do. Please add a feature test for the new
command; see features/ for inspiration.

To try Geordi locally, call it like this:

    # -I means "add the following directory to load path"
    ruby -Ilib exe/geordi
    
    # From another directory
    ruby -I ../geordi/lib ../geordi/exe/geordi

    # With debugger
    ruby -r byebug -I ../geordi/lib ../geordi/exe/geordi

You can also *install* Geordi locally from its project directory with
`rake install`. Make sure to switch to the expected Ruby version before.
