# Changelog

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased

### Compatible changes

### Breaking changes


## 7.0.2 2021-10-06

### Compatible changes
* fix `YAML.safe_load` for `psych` >= 4

## 7.0.1 2021-08-13

### Compatible changes
* Fix missing `thor` dependency

## 7.0.0 2021-08-25

### Breaking changes
* Drop support for Ruby < 2.5.0


## 6.1.0 2021-07-15

### Compatible changes
* Improve parsing of Capistrano files ([#162](https://github.com/makandra/geordi/issues/162))
* `geordi tests` now takes test files as arguments and passes them to either RSpec or Cucumber ([#152](https://github.com/makandra/geordi/issues/152))


## 6.0.0 2021-06-02

### Compatible changes
* `geordi commit` will continue even if one of the given projects is inaccessible. It will only fail if no stories could be found at all.

### Breaking changes
* Removed VNC test browser support for integration tests – Headless Chrome has
  matured and is almost a drop-in replacement. Also, key binding issues have
  increased with VNC and recent Linux.
  * Please use a headless Chrome setup <https://makandracards.com/makandra/492109-capybara-running-tests-with-headless-chrome>. 
  * You might also want to get rid of your local VNC server `sudo apt remove tightvncserver`.
* Removed support for serial execution of scenarios tagged with @solo. Serial
  execution is not needed with Headless Chrome, as Headless instances cannot
  interfere (like, stealing focus).


## 5.4.0 2021-02-01

### Compatible changes
* Add `geordi branch` command that checks out a feature branch based on a story from Pivotal Tracker
* Faster MySQL dumping with [`--single-transaction` and `--quick`](https://dev.mysql.com/doc/refman/5.7/en/mysqldump.html#option_mysqldump_single-transaction)
* Allow pivotal tracker ids in the global config file
* Fix missing require for `Fileutils` in the dump load command (#145)
* Document `PARALLEL_TEST_PROCESSORS`


## 5.3.0 2021-02-01

### Compatible changes
* Changed: Dumping and loading a database will not keep the database dump in `tmp/` but delete it once the operation finishes successfully. Example: `geordi dump staging -l` will remove the file `tmp/staging.dump` after it loaded the dump.


## 5.2.4 2021-01-29

### Compatible changes
* Fix and improve delete-dumps command (now supporting multiple arguments)


## 5.2.3 2021-01-27

### Compatible changes
* Remove auto-bundling from `geordi shell` and remote `geordi console`


## 5.2.2 2020-12-17

### Compatible changes
* Ignore ACL settings when loading a PostgreSQL dump


## 5.2.1 2020-12-15

### Compatible changes
* Fix a bug regarding `geordi vnc` which was introduced in 5.1.0


## 5.2.0 2020-12-14

### Compatible changes
* Geordi update will exit with a warning when Ruby version changes during pull.
* Add `geordi docker` command with support for opening a shell for dockerized dev environments.


## 5.1.0 2020-12-04

### Compatible changes
* Switch to tightvncserver to be compatible with Ubuntu 20.04. vnc4server is still supported.


## 5.0.0 2020-11-25

### Breaking changes
* Remove support for Ruby 2.0 and 2.1


## 4.2.0 2020-10-02

### Compatible changes
* Add `auto_update_chromedriver` as global setting option to automatically update chromedriver before cucumber 
  tests, if Chrome and chromedriver versions don't match.
* Dump command: Add support for multiple databases (#103 by @kajatiger)
* Add Ruby 2.7 to list of supported Ruby versions
* Fix #115: `geordi cucumber --modified` command, that corrupted filenames like:
  ```
  No such file or directory tures/pages.feature
  ```
* Avoid writing an instance of HighLine::String to Geordi config files (closes #114)


## 4.1.1 2020-08-28
### Compatible changes

* Fixed: System calls are not executed properly if no bin stub is present. This resulted in errors like:

  ```
  % geordi rspec

  # Running specs
  > All specs at once (using parallel_tests)

  x Specs failed.
  ```

  or

  ```
  % geordi migrate

  # Migrating
  > Development and parallel test databases

  x Something went wrong.
  ```


## 4.1.0 2020-08-18

### Compatible changes

- Added dumple option `--compress` to compress after dumping

## 4.0.1 2020-08-11

### Compatible changes

- Fix `geordi migrate` command, that fails with:

```
Don't know how to build task 'db:migrate parallel:prepare'
```


## 4.0.0 2020-07-30

### Compatible changes
- Improved documentation; README now includes command options.
- Fix #90: `geordi console`, `geordi deploy`, `geordi rake` and `geordi shell` now work correctly if the project hasn't been bundled before

### Breaking changes
- Removed deprecated executables
- Removed `eurest` command
- Respect binstubs if available, otherwise fallback to geordi's previous behaviour. Note that this might cause failures, when your binstubs are not working. Please have a look at #109 for how a failure might look like and how you can fix it.


## 3.2.0 2020-07-15

### Compatible changes
- Improvement #43: `--select-server` option on `geordi shell` and `geordi console` can take the number of the server to connect to it directly and to skip the menu.
- Add a `.geordi.yml` file to change multiple settings in the project and  `~/.config/geordi/global.yml` for global settings.
- Deprecated the `.pt_project_id` file in favor of `.geordi.yml`.
- Deprecated the `~/.gitpt` file in favor of `~/.config/geordi/global.yml`.
- Add #91: Now there is an option to start cucumber without a VNC session. This is configured by the .geordi.yml file.
- Fixed `git#staged_changes?` detection on Ruby < 2.5.


## 3.1.0 2020-06-03

### Compatible changes
- Update security-update for improved workflow (#89): Deploy staging first and ask user, if application is still running. Then deploy other stages.


## 3.0.3 2020-05-27

### Compatible changes
- Fix #98: Changing the `config/database.yml` reader from `YAML.load` to `YAML.safe_load` dropped the support for aliases. We now allow aliases and the classes `Time` and `Symbol`. If we encounter further issues with this approach a revert to `YAML.load` would be an option, too.


## 3.0.2 2020-05-18

### Compatible changes
- Fix #95: Method change from `! *.include?` to `*.exclude?` was not valid as we do not have active support in Geordi. Affected commands were `geordi cucumber` and `geordi deploy`.


## 3.0.1 2020-05-13

### Compatible changes
- Fix #93: Using `$CHILDSTATUS` instead of `$?` did not work properly. This affected commands like `geordi drop-databases` to fail.
- Fix #92: Geordi fail messages were converted to exceptions by accident. Now they are printed as red error message without the backtrace again.


## 3.0.0 2020-05-04

### Breaking changes
- Remove support for Ruby 1.8.7 and Ruby 1.9.3. Bug fixes might still be backported to 2.x, but we will not add any features to 2.x anymore. Please consider to upgrade the Ruby version of your project.

## 2.12.3

* Add `geordi docker` command with support for opening a shell for dockerized dev environments.

## 2.11.0 2020-05-04

### Compatible changes
- Added the possibility to change the Rails root for the capistrano config via the environment variable `RAILS_ROOT`. This allows you as a gem developer to run a command like `RAILS_ROOT=~/Projects/my-blog geordi console staging` whereas `geordi` uses the capistrano config from `my-blog`. Otherwise you would need to follow the instructions of [this card](https://makandracards.com/makandra/46617-how-to-use-a-local-gem-in-your-gemfile) to test changes in the gem locally.
- Bug fix for "no staged changes" even if there are changes present (#83).
- Fixed deprecation warning for `Thor exit with status 0 on errors` (#84).
- Replaced `Bundler.with_unbundled_env` with `Bundler.with_original_env` (#77). This is a better replacement than 42cd1c4.
- Add deprecation warning `Deprecation warning: Ruby 1.8.7 and 1.9.3 support will be dropped in Geordi 3.x.` to Geordi 2.
- Fix error `thor requires Ruby version >= 2.0.0` for Ruby 1.8.7 and 1.9.3 (https://github.com/makandra/geordi/issues/79#issuecomment-598664191).

### Breaking changes


## 2.10.1 2020-02-17

### Compatible changes
- Add host parameter to mysql dump loader

## 2.10.0 2020-02-11

### Compatible changes
- Fixes [#78](https://github.com/makandra/geordi/pull/78): Add compatibility for more than 9 CPU cores in
  `geordi drop-databases`.


## 2.9.0 2020-01-03

### Compatible changes
- Fixes [#37](https://github.com/makandra/geordi/issues/37): `geordi cucumber` crashes with `--format=pretty`
- Fixes [#27](https://github.com/makandra/geordi/issues/27): Cucumber rerun switch does work when passing files


## 2.8.0 2020-01-02

### Compatible changes
- Fixed [#77](https://github.com/makandra/geordi/issues/77): Remove deprecation warning for "Bundler.clean_system"


## 2.7.0 2019-11-25

### Compatible changes
- Fixed [#68](https://github.com/makandra/geordi/issues/68): The "cucumber" command now fails early when @solo features fail.
- Added: The "setup" command now prints the db adapter when prompting db credentials.
- Fixed [#71](https://github.com/makandra/geordi/issues/71): When used without staged changes, the "commit" command will print a warning and create an empty commit. Any arguments to the command are forwarded to Git.
- Fixed: The "commit" command will not print the extra message any more.
- Added: The "commit" command prints a (progress) loading message. The message is removed once loading is done.


## 2.6.0 2019-11-04

### Compatible changes
- Added [#73](https://github.com/makandra/geordi/issues/73): New command `chromdriver-update` allows you to update your
  chromedriver to the newest matching version.


## 2.5.0 2019-10-25

### Compatible changes
- Added [#69](https://github.com/makandra/geordi/issues/69): If bin/setup exists, prefer it over Geordi's standard setup routine.
- Fixed [#48](https://github.com/makandra/geordi/issues/48): Bundle right before deploying
- Improved [#56](https://github.com/makandra/geordi/issues/56): Print instructions how to set up `DEPLOY_BRANCH` when deploying the current branch.


## 2.4.0 2019-10-21

### Compatible changes
- [#56](https://github.com/makandra/geordi/issues/56): Add current branch option to "deploy" command. This actually sets the `DEPLOY_BRANCH` variable to the current branch during deployment. The deployed application needs to pick up this variable in the respective Capistrano stage file. Example: `set :branch, ENV['DEPLOY_BRANCH'] || 'master'`


## 2.3.0 2019-08-27

### Compatible changes
- Fixes [#70]: Make "console" and "server" commands ready for Rails 6
- Added: CI testing with Travis


## 2.2.0 2019-02-28

### Compatible changes
- Fixes [#67]: Don't run yarn install unless needed


## 2.1.0 2019-02-25

### Compatible changes
- Fixes [#59]: Removedb name prefix when reading whitelist
- Fixes [#62]: Provide better error messages on whitelist editing errors.
- Fixes [#63]: Allow explicit whitelisting of database names that would be considered derivative during db cleanup
- Fixes [#64]: Remove VISUAL and EDITOR from editor choices for DB whitelist editing

## 2.0.0 2019-02-20

### Breaking changes
- Pivotal Tracker discontinued API V3 and V4. We now use API V5, which has a client library that does not support Ruby
  version < 2.1 anymore (all other geordi commands will still work for older Ruby versions).
  Run `gem uninstall pivotal-tracker` and `gem install tracker_api` to migrate `geordi` installed in a Ruby version >= 2.1.

### Compatible changes
- Fixes [#54]: @solo features run first and are not skipped by accident on failures before
- Fixes [#03]: Add spring support for RSpec
- Fixes [#53]: Integrate yarn integrity
- Fixes [#52]: Remote dumps are transmitted compressed

## 1.11.0 2018-11-07

### Compatible changes
- Fixes [#36](https://github.com/makandra/geordi/issues/36): Capistrano Config: Settings in deploy/$stage.rb should take precedence over deploy.rb
- Fixes [#38](https://github.com/makandra/geordi/issues/31): Capistrano Config: Ignore whitespaces in the capistrano config files

## 1.10.0 2018-10-17

### Compatible changes
- Fixes [#44](https://github.com/makandra/geordi/issues/44): Geordi now supports a multiline server definition.

  Example:

  ```
  server 'c01.test.example.com',
    user: 'deploy-test_p',
    roles: ['app', 'web', 'db', 'cron', 'primary_cron'],
    primary: true
  ```

- Added this CHANGELOG file.
