# Changelog
All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).


## Unreleased

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
