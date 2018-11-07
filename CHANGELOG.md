# Changelog
All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).


## Unreleased

## 1.11.0 2018-11-07

### Compatible changes
- Fixes [#36](https://github.com/makandra/geordi/issues/36): Capistrano Config: Settings in deploy/$stage.rb should take precedence over deploy.rb

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
