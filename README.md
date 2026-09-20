# Celerbrake

**Celerbrake** is the Ruby/Rails integration gem for
[Celerbrake][celerbrake] — a self-hosted error- and exception-tracking service.
Add it to a Rack-compliant app and unhandled exceptions are captured and shipped
to your Celerbrake instance automatically, with full backtraces, request
context, and per-error grouping.

It builds on the [`celerbrake-ruby`][celerbrake-ruby] notifier and adds
out-of-the-box integrations for Rails, Sinatra, Sidekiq, Resque, Delayed Job,
Shoryuken, Sneakers, ActiveJob, Rack, and more.

> **Heritage.** Celerbrake began as a fork of the
> [airbrake][airbrake] gem (v13.0.2) and stays wire-compatible with the Airbrake
> v3 `create-notice` API. The difference is where your errors go: a Celerbrake
> instance you run, rather than a third-party service. We're grateful to Airbrake
> Technologies, Inc. for the original, MIT-licensed work — see
> [LICENSE.md](LICENSE.md).

## Installation

### Bundler

```ruby
gem 'celerbrake'
```

### Manual

```bash
gem install celerbrake
```

## Rails

Generate the initializer with your project credentials (find these on your
Celerbrake instance under `/admin/projects/:id`):

```bash
bundle exec rails generate celerbrake PROJECT_ID PROJECT_KEY
```

This writes `config/initializers/celerbrake.rb`. The generated initializer reads
from environment variables, so you can also set credentials without
regenerating:

```bash
CELERBRAKE_PROJECT_ID=1
CELERBRAKE_PROJECT_KEY=...the api_key from the admin page...
```

**Always point the gem at your own instance.** The host baked into
`celerbrake-ruby`'s config (`https://api.celerbrake.com`) is a leftover from the
fork and **no longer resolves**, and nothing warns you: an unset host means
notices report into a DNS hole. Changing that default is a separate decision,
because it means a lockfile bump and a redeploy for every app on the fleet, so
set the host yourself:

```ruby
# config/initializers/celerbrake.rb
Celerbrake.configure do |c|
  c.project_id  = ENV.fetch('CELERBRAKE_PROJECT_ID').to_i
  c.project_key = ENV.fetch('CELERBRAKE_PROJECT_KEY')
  c.host        = ENV.fetch('CELERBRAKE_HOST') # e.g. https://celerbrake.com
  c.environment = Rails.env
  c.ignore_environments = %w[development test]
end
```

Once configured, Celerbrake installs its Rack middleware, subscribes to Rails
instrumentation, and hooks ActiveJob — unhandled exceptions are reported with no
further code.

## Plain Ruby / other frameworks

For non-Rails apps, configure `celerbrake-ruby` directly and require only the
integrations you need:

```ruby
require 'celerbrake'

Celerbrake.configure do |c|
  c.project_id  = 123
  c.project_key = 'fa0123456789abcdef0123456789abcd'
  c.host        = 'https://errors.example.com'
end
```

```ruby
require 'celerbrake/sidekiq'   # Sidekiq middleware
require 'celerbrake/resque'    # Resque failure backend
require 'celerbrake/rack'      # Generic Rack middleware
require 'celerbrake/delayed_job'
```

## Sending a notice manually

```ruby
begin
  raise 'Oops!'
rescue => exception
  Celerbrake.notify(exception)
end
```

See [`celerbrake-ruby`][celerbrake-ruby] for the full notifier API
(`notify`, `notify_sync`, filters, blocklist keys, and configuration options).

## Supported integrations

Rails (Railtie, ActiveJob, ActionCable, ActiveRecord, ActionController), Rack,
Sinatra, Sidekiq, Resque, Delayed Job, Shoryuken, Sneakers, Capistrano, and Rake
— the same set shipped by the upstream gem.

## Contributing

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

Celerbrake is released under the [MIT License](LICENSE.md). It is a derivative
work of the [airbrake][airbrake] gem, also MIT-licensed; the original copyright
is preserved in `LICENSE.md`.

[celerbrake]:      https://celerbrake.com
[celerbrake-ruby]: https://github.com/celerbrake/celerbrake-ruby
[airbrake]:        https://github.com/airbrake/airbrake
