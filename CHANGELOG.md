# Changelog
All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).


## Unreleased
### Compatible changes
- Fixed [#77](https://github.com/makandra/geordi/issues/77): Remove deprecation warning for "Bundler.clean_system"
### Breaking changes


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
