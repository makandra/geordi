<p>
  <a href="https://makandra.de/">
    <picture>
      <source media="(prefers-color-scheme: light)" srcset="media/makandra-with-bottom-margin.light.svg">
      <source media="(prefers-color-scheme: dark)" srcset="media/makandra-with-bottom-margin.dark.svg">
      <img align="right" width="25%" alt="makandra" src="media/makandra-with-bottom-margin.light.svg">
    </picture>
  </a>

  <picture>
    <source media="(prefers-color-scheme: light)" srcset="media/logo.light.shapes.svg">
    <source media="(prefers-color-scheme: dark)" srcset="media/logo.dark.shapes.svg">
    <img width="140" alt="Geordi" role="heading" aria-level="1" src="media/logo.light.shapes.svg">
  </picture>
</p>

[![Tests](https://github.com/makandra/geordi/workflows/Tests/badge.svg)](https://github.com/makandra/geordi/actions)


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

Commands will occasionally print "did you know" hints of other Geordi features.

You can always run `geordi help <command>` to quickly look up command help.

### `geordi branch`
Check out a feature branch based on a Linear issue.

Example: `geordi branch`

On the first execution we ask for your Linear API token. It will be
stored in `~/.config/geordi/global.yml`.

**Options**
- `-m, --from-main, --from-master`: Branch from master instead of the current branch


### `geordi capistrano COMMAND`
Run a Capistrano command on all deploy targets.

Example: `geordi capistrano deploy`


### `geordi chromedriver-update`
Update the chromedriver.

Example: `geordi chromedriver_update`

This command will find and install the matching chromedriver for the currently
installed Chrome.

Setting `auto_update_chromedriver` to `true` in your global Geordi config file 
(`~/.config/geordi/global.yml`), will automatically update chromedriver before 
cucumber tests if a newer chromedriver version is available.


### `geordi clean`
Remove unneeded files from the current directory.


### `geordi commit`
Commit using an issue title from Linear.

Example: `geordi commit`

Any extra arguments are forwarded to `git commit -m <message>`.

On the first execution we ask for your Linear API token. It will be
stored in `~/.config/geordi/global.yml`.


### `geordi console [TARGET]`
Open a Rails console locally or on a Capistrano deploy target.

Local (development): `geordi console`

Remote: `geordi console staging`

Selecting the server: `geordi console staging -s` shows a menu with all available
servers. When passed a number, directly connects to the selected server.

IRB flags can be given as `irb_flags: '...'` in the global or local Geordi config file
(`~/.config/geordi/global.yml` / `./.geordi.yml`). If you define irb_flags in both files, the local config file will be
used. For IRB >=1.2 in combination with Ruby <3 geordi automatically sets the `--nomultiline` flag, to prevent slow
pasting. You can override this behavior by setting `--multiline` in the global config file or by defining `irb_flags` 
in the local config file. The latter will always turn off the automatic behavior, even if you don't set any values for 
the irb_flags key.

**Options**
- `-s, --select-server=[SERVER_NUMBER]`: Select a server to connect to


### `geordi cucumber [FILES and OPTIONS]`
Run Cucumber features.

Example: `geordi cucumber features/authentication_feature:3`

Runs Cucumber with `bundle exec`, using parallel tests and with support for
re-running failed scenarios.

Any unknown option will be passed through to Cucumber, e.g. `--format=pretty`.
Make sure to connect option and value with an equals sign, i.e. have each option
a contiguous string.

In order to limit processes in a parallel run, you can set an environment
variable like this: `PARALLEL_TEST_PROCESSORS=6 geordi cucumber`

**Options**
- `-m, --modified`: Run all modified features
- `-c, --containing=STRING`: Run all features that contain STRING
- `-v, --verbose`: Show the test run command
- `-d, --debug`: Run Cucumber with `-f pretty -b`, which helps hunting down bugs
- `-r, --rerun=N`: Rerun features up to N times while failing


### `geordi delete-dumps [DIRECTORY]`
Help deleting database dump files (*.dump).

Example: `geordi delete-dumps` or `geordi delete-dumps ~/tmp/dumps`

Recursively searches for files ending in `.dump` and offers to delete them. When
no argument is given, two default directories are searched for dump files: the
current working directory and `~/dumps` (for dumps created with geordi).

Will ask for confirmation before actually deleting files.


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
current branch and fall back to master/staging. (Will use the actual main branch
of the repository, e.g. "main" instead of "master".)

Finds available Capistrano stages by their prefix, e.g. `geordi deploy p` will
deploy production, `geordi deploy mak` will deploy a `makandra` stage if there
is a file config/deploy/makandra.rb.

If Linear team ids are configured (see `geordi commit`'), will offer to move deployed issues to a new state. 

When your project is running Capistrano 3, deployment will use `cap deploy`
instead of `cap deploy:migrations`. You can force using `deploy` by passing the
-M option: `geordi deploy -M staging`.

**Options**
- `-M, --no-migrations`: Run cap deploy instead of cap deploy:migrations
- `-c, --current-branch`: Set DEPLOY_BRANCH to the current branch during deploy


### `geordi drop-databases`
Interactively delete local databases.

Example: `geordi drop_databases`

Check both MySQL/MariaDB and Postgres on the machine running geordi for databases
and offer to delete them. Excluded are databases that are whitelisted. This comes
in handy when you're keeping your currently active projects in the whitelist files
and perform regular housekeeping with Geordi.

Per default, Geordi will try to connect to the databases as a local user without 
password authorization.  

Geordi will ask for confirmation before actually dropping databases and will
offer to edit the whitelist instead.

**Options**
- `-P, --postgres-only`: Only clean PostgreSQL
- `-M, --mysql-only`: Only clean MySQL/MariaDB
- `--postgres=PORT_OR_SOCKET`: Use PostgreSQL port or socket
- `--mysql=PORT_OR_SOCKET`: Use MySQL/MariaDB port or socket
- `-S, --sudo`: Access databases as root


### `geordi dump [TARGET]`
Handle (remote) database dumps.

`geordi dump` (without arguments) dumps the development database with `dumple`.

`geordi dump -l tmp/staging.dump` (with the `--load` option) sources the
specified dump file into the development database.

`geordi dump staging` (with a Capistrano deploy target) remotely dumps the
specified target's database and downloads it to `tmp/`.

`geordi dump staging -l` (with a Capistrano deploy target and the `--load`
option) sources the dump into the development database after downloading it.

If you are using multiple databases per environment, Geordi defaults to the
"primary" database, or the first entry in database.yml. To target a specific
database, pass the database name like this:
```
geordi dump -d primary
```

When used with the blank `load` option ("dump and source"), the `database` option
will be respected both for the remote *and* the local database. If these should
not match, please issue separate commands for dumping (`dump -d`) and sourcing
(`dump -l -d`).

**Options**
- `-l, --load=[DUMP_FILE]`: Load a dump
- `-d, --database=NAME`: Target database, if there are multiple databases


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

Runs RSpec with version 1/2 support, parallel_tests detection and `bundle exec`.

In order to limit processes in a parallel run, you can set an environment
variable like this: `PARALLEL_TEST_PROCESSORS=6 geordi rspec`


### `geordi security-update [STEP]`
Support for performing security updates.

Preparation for security update: `geordi security-update`. Checks out production
and pulls, and will tell each step before performing it.

Part two after performing the update: `geordi security-update finish`. Switches
branches, pulls, pushes and deploys as required by our workflow. This as well
will tell each step before performing it.


### `geordi server [PORT]`
Start a development server.

**Options**
- `-p, --port=PORT`: Choose a port
- `-P, --public`: Make the server accessible from the local network


### `geordi setup`
Setup a project for the first time.

Example: `geordi setup`

Check out a repository and cd into its directory. Then let `setup` do the tiring
work: run `bundle install`, create `database.yml`, create databases, migrate
(all if applicable).

If a local bin/setup file is found, Geordi skips its routine and runs bin/setup
instead.

**Options**
- `-d, --dump=TARGET`: After setup, dump the TARGET db and source it into the development db
- `-t, --test`: After setup, run tests


### `geordi shell TARGET`
Open a shell on a Capistrano deploy target.

Example: `geordi shell production`

Selecting the server: `geordi shell staging -s` shows a menu with all available
servers. When passed a number, directly connects to the selected server.

**Options**
- `-s, --select-server=[SERVER_NUMBER]`: Select a server to connect to


### `geordi tests [FILES]`
Run all employed tests.

When running `geordi tests` without any arguments, all unit tests, rspec specs
and cucumber features will be run.

When passing file paths or directories as arguments, Geordi will forward them to `rspec` and `cucumber`. 
All rspec specs and cucumber features matching the given paths will be run.


### `geordi unit`
Run Test::Unit.

Supports `parallel_tests`, binstubs and `bundle exec`.

In order to limit processes in a parallel run, you can set an environment
variable like this: `PARALLEL_TEST_PROCESSORS=6 geordi unit`


### `geordi update`
Bring a project up to date.

Example: `geordi update`

Performs: `git pull`, `bundle install` (if necessary) and migrates (if applicable).

**Options**
- `-d, --dump=TARGET`: After updating, dump the TARGET db and source it into the development db
- `-t, --test`: After updating, run tests


### `geordi version`
Print the current version of geordi.

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

**Options**
- `-i`: Print disk usage of `~/dumps`
- `--compress`: After dumping, run gzip to compress the dump in place


Contributing
============

When making changes to Geordi, please make sure your code is tested. Not all,
but most features of Geordi can be tested. See other tests for inspiration.

Once you have completed your modifications, please update CHANGELOG and README
as needed. Use `rake readme` to regenerate the Geordi section of the README from
the command documentations.

Make sure tests are green in the oldest supported Ruby version. Before releasing
a new gem version, wait for the CI results to see that tests are green in all
Ruby versions.


Adding a new command
---------------

Copy `lib/geordi/COMMAND_TEMPLATE` to `lib/geordi/commands/your_command` and
edit it to do what you need it to do. Please add appropriate tests for the new
command; see existing tests for inspiration.


Running Geordi locally
----------------------

To run Geordi without installation, call it like this:

    ruby -I lib exe/geordi

    # With debugger
    ruby -r byebug -I lib exe/geordi

    # From another directory
    ruby -I ../geordi/lib ../geordi/exe/geordi

    # Run Geordi with the Ruby version of that other directory
    RBENV_VERSION=$(<.ruby-version) ruby -I ../geordi/lib ../geordi/exe/geordi

You can also *install* Geordi locally from its project directory with
`rake install`. Make sure to switch to the expected Ruby version before.
