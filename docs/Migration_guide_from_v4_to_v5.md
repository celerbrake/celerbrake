Migration guide from v4 to v5
=============================

* [Celerbrake README](https://github.com/celerbrake/celerbrake)
* [Celerbrake Ruby README](https://github.com/celerbrake/celerbrake-ruby)
* [YARD API documentation](http://www.rubydoc.info/gems/celerbrake-ruby)

The Celerbrake gem v5 release introduced [new
features](https://github.com/celerbrake/celerbrake/blob/master/CHANGELOG.md#v500),
bug fixes and some breaking changes. Don't worry, we tried to make this
transition as smooth as possible. This guide will help you to upgrade from
Celerbrake v4 to Celerbrake v5.

The most prominent change is that the Celerbrake gem was split into two gems:
`celerbrake` and `celerbrake-ruby`. The `celerbrake-ruby` gem is the core gem, which
defines how to send notices. The `celerbrake` gem contains integrations with web
frameworks and other software.

Please note, that we still _do support_ Celerbrake v4 for quite some
time. However, it is _feature frozen_.

Migration Instructions
----------------------

* [General changes](#general-changes)
  * [Configuration](#configuration)
  * [Library API](#library-api)
  * [Other changes](#other-changes)
* [Integration changes](#integration-changes)
  * [Heroku](#heroku)
  * [Rails](#rails)
  * [Rack applications](#rack-applications)
  * [Resque](#resque)
  * [Sidekiq](#sidekiq)
  * [Deployment with Rake task](#deployment-with-rake-task)
  * [Capistrano](#capistrano)

### General changes

#### Configuration

Old option | New option | required?
---|---|---
api_key | [project_key](#api-key) | required
n/a | [project_id](#project-id) | required
development_environments | [ignore_environments](#development-environments) | optional
port | [host](#port) | optional
secure | [host](#secure) | optional
proxy_host | [proxy](#proxy)| optional
proxy_port | [proxy](#proxy)| optional
proxy_user | [proxy](#proxy)| optional
proxy_pass | [proxy](#proxy)| optional
params_filter | [add_filter](#filtering) | optional
params_whitelist_filter | [add_filter](#filtering) | optional
backtrace_filters | [add_filter](#filtering) | optional
ignore_by_filters | [add_filter](#filtering) | optional
rake_environment_filters | [add_filter](#filtering) | optional
ignore | [add_filter](#filtering) | optional
ignore_rake | [add_filter](#filtering) | optional
ignore_user_agent | [add_filter](#filtering) | optional
ignore_only | [add_filter](#filtering) | optional
environment_name | [environment](#environment-name) | optional
project_root | [root_directory](#project-root) | optional
async | removed ([async by default](#notify)) | n/a
http_open_timeout | removed | n/a
development_lookup | removed | n/a
notifier_name | removed | n/a
notifier_url | removed | n/a
notifier_version | removed | n/a
user_information | removed | n/a
framework | removed | n/a
rescue_rake_exceptions | removed | n/a
user_attributes | removed ([autodetected](#user-attributes))| n/a
test_mode | removed | n/a

* <a name="api-key"></a>
  The `api_key` option was renamed to `project_key`.
<sup>[[link](#api-key)]</sup>

  ```ruby
  # Old way
  Celerbrake.configure do |c|
    c.api_key = 'a1b2c3d4e5f6g780'
  end

  # New way
  Celerbrake.configure do |c|
    c.project_key = 'a1b2c3d4e5f6g780'
  end
  ```

* <a name="project-id"></a>
  The new mandatory option - `project_id`. To find your project's id, either
  copy it from the URL or navigate to your project's settings and find these
  fields on the right sidebar.
<sup>[[link](#project-id)]</sup>

  ![][project-idkey]

  ```ruby
  # Old way
  # Didn't exist.

  # New way
  Celerbrake.configure do |c|
    c.project_id = 93597
  end
  ```

* <a name="development-environments"></a>
  The `development_environments` option was renamed to `ignore_environments`.
  Its behaviour was also slightly changed. By default, the library sends
  exceptions in _all_ environments, so you don't need to assign an empty Array
  anymore to get this behavior. If you relied on the default value of
  `development_environments` before upgrading, you should explicitly set
  `ignore_environments` to `%w(development test cucumber)` to preserve the old
  behavior.
<sup>[[link](#development-environments)]</sup>

  ```ruby
  # Old way
  Celerbrake.configure do |c|
    c.development_environments = %w(development test)

    # OR to collect exceptions in all envs

    c.development_environments = []

    # OR don't set this option to get the default (development, test, cucumber)
  end

  # New way
  Celerbrake.configure do |c|
    c.environment = Rails.env
    c.ignore_environments = %w(development test)

    # OR to collection exceptions in all envs

    # Simply don't set this option

    # OR use the old default value

    c.ignore_environments = %w(development test cucumber)
  end
  ```

* <a name="port"></a>
  The `port` option was removed. It was merged with the `host` option. From now
  on simply include your port in your host.
<sup>[[link](#port)]</sup>

  ```ruby
  # Old way
  Celerbrake.configure do |c|
    c.host = 'example.com'
    c.port = 8080
  end

  # New way
  Celerbrake.configure do |c|
    c.host = 'http://example.com:8080'
  end
  ```

* <a name="secure"></a>
  The `secure` option was removed. It was merged with the `host` option. From
  now on simply specify your protocol, when you define `host`. The library will
  guess the mode based on the URL scheme (HTTP or HTTPS).
<sup>[[link](#secure)]</sup>

  ```ruby
  # Old way
  Celerbrake.configure do |c|
    c.host = 'example.com'
    c.secure = true
  end

  # New way
  Celerbrake.configure do |c|
    c.host = 'https://example.com'
  end
  ```

* <a name="http-open-timeout"></a>
  The `http_open_timeout` & `http_read_timeout` options were removed.
<sup>[[link](#http-open-timeout)]</sup>

* <a name="proxy"></a>
  The `proxy_host`, `proxy_port`, `proxy_user` & `proxy_pass` options were
  merged into one option - `proxy`. It accepts a Hash with the `host`, `port`,
  `user` & `password` keys.
<sup>[[link](#proxy)]</sup>

  ```ruby
  # Old way
  Celerbrake.configure do |c|
    c.proxy_host = 'example.com'
    c.proxy_port = 8080
    c.proxy_user = 'user'
    c.proxy_pass = 'p4ssw0rd'
  end

  # New way
  Celerbrake.configure do |c|
    c.proxy = {
      host: 'example.com',
      port: 8080,
      user: 'user',
      password: 'p4ssw0rd',
    }
  end
  ```

* <a name="params-filters"></a>
  The `params_filters` option was replaced with the
  [blacklist filter](#blacklist-filter).
<sup>[[link](#params-filters)]</sup>

* <a name="params-whitelist-filters"></a>
  The `params_whitelist_filters` option was replaced with the [whitelist
  filter](#whitelist-filter)
<sup>[[link](#whitelist-filter)]</sup>

* <a name="filtering"></a>
  The `backtrace_filters`, `ignore_by_filters`, `rake_environment_filters`,
  `ignore`, `ignore_rake`, `ignore_user_agent` & `ignore_only` options were
  replaced with the [`add_filter` API](#ignore-by-filter).
<sup>[[link](#filtering)]</sup>

* <a name="development-lookup"></a>
  The `development_lookup` option was removed.
<sup>[[link](#development-lookup)]</sup>

* <a name="environment-name"></a>
  The `environment_name` was renamed to `environment`.
<sup>[[link](#environment-name)]</sup>

  ```ruby
  # Old way
  Celerbrake.configure do |c|
    c.environment_name = 'staging'
  end

  # New way
  Celerbrake.configure do |c|
    c.environment = 'staging'
  end
  ```

* <a name="project-root"></a>
  The `project_root` option was renamed to `root_directory`.
<sup>[[link](#project-root)]</sup>

  NOTE: you *must* set this if you want Celerbrake backtraces to link to
  GitHub. In Rails projects this value should typically be equal to
  `Rails.root`.

  ```ruby
  # Old way
  Celerbrake.configure do |c|
    c.project_root = '/var/www/project'
  end

  # New way
  Celerbrake.configure do |c|
    c.root_directory = '/var/www/project'
  end
  ```

* <a name="notifier-name"></a>
  The `notifier_name`, `notifier_url` & `notifier_version` options were removed.
<sup>[[link](#notifier-name)]</sup>

* <a name="user-information"></a>
  The `user_information` option was removed.
<sup>[[link](#user-information)]</sup>

* <a name="framework"></a>
  The `framework` option was removed.
<sup>[[link](#framework)]</sup>

* <a name="rescue-rake"></a>
  The `rescue_rake_exceptions` option was removed.
<sup>[[link](#rescue-rake)]</sup>

* <a name="user-attributes"></a>
  The `user_attributes` option was removed.
  Celerbrake will automatically include `:id`, `:name`, `:username` and `:email` attributes.
  If `:name` is not available Celerbrake will build it from `:first_name` and `:last_name`.
<sup>[[link](#user-attributes)]</sup>

* <a name="test-mode"></a>
  The `test_mode` option was removed.
<sup>[[link](#test-mode)]</sup>

* <a name="async"></a>
  The `async` option was removed. Celerbrake is now async by default.
  Read the [`Celerbrake.notify` docs](#celerbrake-notify) for more information.
<sup>[[link](#async)]</sup>

* <a name="default-ignored-classes"></a>
  The list of default ignored exceptions was relaxed. The library now ignores
  only `SystemExit` exceptions.
<sup>[[link](#default-ignored-classes)]</sup>

* <a name="filter-parameters"></a>
  Celerbrake no longer reuses filters specified by
  `Rails.application.config.filter_parameters`. Instead, use the
  [`add_filter` API](#filtering).
<sup>[[link](#filter-parameters)]</sup>

#### Library API

##### Blacklist filter

Instead of [various filter options](#params-filters) the library supports
blacklist filtering. The blacklist filter is global, which means it filters
every matching key in the notice's payload.

###### Celerbrake v5.2.0+

```ruby
# Old way
Celerbrake.configure do |c|
  c.params_filters << 'credit_card_number'
end

# New way
Celerbrake.configure do |c|
  c.blacklist_keys << 'credit_card_number'
end
```

###### Celerbrake v5.0.0-v5.1.0 API (deprecated)

```ruby
Celerbrake.blacklist_keys([:credit_card_number])
```

##### Whitelist filter

Instead of [various filter options](#params-whitelist-filters) the library
supports whitelist filtering. The whitelist filter is global, which means it
filters every key except the specified ones.

###### Celerbrake v5.2.0+

```ruby
# Old way
Celerbrake.configure do |c|
  c.params_whitelist_filters << 'email'
end

# New way
Celerbrake.configure do |c|
  c.whitelist_keys << [:email]
end
```

###### Celerbrake v5.0.0-v5.1.0 API (deprecated)

```ruby
Celerbrake.whitelist_keys([:email])
```

##### Ignore by filter

Since the `ignore_by_filter` option was removed, the new API was introduced -
`Celerbrake.add_filter`. The API is similar to `ignore_by_filter`, but
`.add_filter` doesn't rely on return values. Instead, you can mark notices as
ignored with help of the `Celerbrake::Notice#ignore!` method. `Celerbrake.add_filter`
replaces a lot of [legacy options](#filtering).

```ruby
# Old way
Celerbrake.configure do |c|
  c.ignore_by_filter do |exception_data|
    true if exception_data[:error_class] == "RuntimeError"
  end
end

# New way
Celerbrake.add_filter do |notice|
  # The library supports nested exceptions, so one notice can carry several
  # exceptions.
  if notice[:errors].any? { |error| error[:type] == 'RuntimeError' }
    notice.ignore!
  end
end
```

The `notice` that `add_filter` yields is an instance of `Celerbrake::Notice`. Its
public API is [described in the `celerbrake-ruby`
README](https://github.com/celerbrake/celerbrake-ruby#notice).

##### Notify

* <a name="celerbrake-notify"></a>
  `Celerbrake.notify` is now async. To be able to send exceptions synchronously,
  the `Celerbrake.notify_sync` method was added. Both methods have the same
  method signature.
<sup>[[link](#celerbrake-notify)]</sup>

  The list of accepted arguments was amended. The first argument can now
  additionally accept Strings. The second argument is still a Hash, but the
  difference is that anything you pass there will be added to the Params tab.
  The support for `api_key`, `error_message`, `backtrace`, `parameters` and
  `session` was removed.

  ```ruby
  # Old way
  Celerbrake.notify(
    RuntimeError.new('Oops'),
    api_key: '1a2b3c4d5e6f7890',
    error_message: 'Notification',
    backtrace: caller,
    parameters: {},
    session: {}
  )

  # New way
  Celerbrake.notify('Oops', this_will_be: 'prepended to the Params tab')
  ```

* <a name="notify-or-ignore"></a>
  `Celerbrake.notify_or_ignore` was removed.
<sup>[[link](#notify-or-ignore)]</sup>

#### Other changes

* <a name="env"></a>
  The library no longer sends `ENV` by default. If you need this behaviour,
  use the [`add_filter` API](#ignore-by-filter).
<sup>[[link](#env)]</sup>

  ```ruby
  Celerbrake.add_filter do |notice|
    notice[:environment].merge!(ENV)
  end
  ```

* <a name="celerbrake-configuration"></a>
  The `Celerbrake.configuration` interface was removed. It's no longer possible
  to read config values.
<sup>[[link](#celerbrake-configuration)]</sup>

* <a name="cli"></a>
  The Celerbrake CLI was removed completely. Instead, it is recommended to use
  [Rake tasks](#deployment-with-rake-task).
<sup>[[link](#cli)]</sup>

* <a name="ca-cert"></a>
  The bundled `ca-bundle.crt` was removed.
<sup>[[link](#ca-cert)]</sup>

### Integration changes

#### Heroku

* <a name="heroku-deploy-hook"></a>
  The deploy hook Rake task was renamed from
  `celerbrake:heroku:add_deploy_notification` to
  `celerbrake:install_heroku_deploy_hook`.
<sup>[[link](#heroku-deploy-hook)]</sup>

  ```shell
  # Old way
  bundle exec rake celerbrake:heroku:add_deploy_notification

  # New way
  bundle exec rake celerbrake:install_heroku_deploy_hook
  ```

* <a name="heroku-generator"></a>
  The way to generate the Celerbrake config was simplified.
<sup>[[link](#heroku-generator)]</sup>

  ```ruby
  # Old way
  rails g celerbrake --api-key `heroku config:get CELERBRAKE_API_KEY`

  # New way
  rails g celerbrake
  ```

#### Rails

* <a name="rails-2-support"></a>
  The support for Rails 2 was dropped. Celerbrake v5 officially supports only
  `3.2.*`, `4.0.*`, `4.1.*`, `4.2.*` and above.
<sup>[[link](#rails-2-support)]</sup>

* <a name="rails-generator"></a>
  The Rails generator was changed to accept two parameters: project id and
  project key. The `--api-key` flag was removed.
<sup>[[link](#rails-generator)]</sup>

  ```ruby
  # Old way
  rails g celerbrake --api-key YOUR_API_KEY

  # New way
  rails g celerbrake YOUR_PROJECT_ID YOUR_API_KEY
  ```

* <a name="rails-notify"></a>
  The `notify_celerbrake` helper method's signature was amended to conform to the
  [`Celerbrake.notify`](#celerbrake-notify) signature.
<sup>[[link](#rails-notify)]</sup>

#### Rack applications

The name of the Celerbrake Rack middle ware was changed from
`Celerbrake::Rails::Middleware` to `Celerbrake::Rack::Middleware`

```ruby
# Old way
use Celerbrake::Rails::Middleware

# New way
use Celerbrake::Rack::Middleware
```

#### Resque

Replace `resque/failure/celerbrake` with `celerbrake/resque/failure`

```ruby
# Old way
require 'resque/failure/celerbrake'
Resque::Failure.backend = Resque::Failure::Celerbrake

# New way
require 'celerbrake/resque/failure'
Resque::Failure.backend = Resque::Failure::Celerbrake
```

#### Sidekiq

Replace `celerbrake/sidekiq` with `celerbrake/sidekiq/error_handler`

```ruby
# Old way
require 'celerbrake/sidekiq'

# New way
require 'celerbrake/sidekiq/error_handler'
```

#### Deployment with Rake task

The list of recognised environment variables passed to the `celerbrake:deploy`
Rake task was changed.

```shell
# Old way
rake celerbrake:deploy USER=john TO=production REVISION=38748467 REPO=https://github.com/celerbrake/celerbrake

# New way
rake celerbrake:deploy USERNAME=john ENVIRONMENT=production REVISION=38748467 REPOSITORY=https://github.com/celerbrake/celerbrake
```

#### Capistrano

There is no longer a difference between integration with Capistrano 2 and 3. For
Capistrano 3 you no longer need an `after` hook.

```ruby
# Old way
# For Capistrano 2
# Capfile
require 'celerbrake/capistrano'
# For Capistrano 3
# Capfile
require 'celerbrake/capistrano3'
# config/deploy.rb
after 'deploy:finished', 'celerbrake:deploy'

# New way
# For Capistrano 2
require 'celerbrake/capistrano/tasks'
# For Capistrano 3
# Capfile
require 'celerbrake/capistrano/tasks'
# config/deploy.rb
after :finished, 'celerbrake:deploy'
```

<div align="right">
  <img src="https://img-fotki.yandex.ru/get/3011/98991937.20/0_bac52_6616f5d4_orig"/>
  <br>
  Happy Airbraking with Celerbrake v5!
  <br>
  The Celerbrake team
</div>

[project-idkey]: https://img-fotki.yandex.ru/get/3907/98991937.1f/0_b558a_c9274e4d_orig
