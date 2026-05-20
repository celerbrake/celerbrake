Celerbrake Changelog
====================

### master

- No pending changes to be released

### [v0.1.0][v0.1.0] (unreleased)

Initial release of Celerbrake.

Celerbrake is a fork of the [airbrake][airbrake] gem v13.0.2. Changes from the
upstream gem:

- Renamed the `Airbrake` module and the `airbrake` gem to `Celerbrake` /
  `celerbrake`.
- Depends on [`celerbrake-ruby`][celerbrake-ruby] (the forked core notifier),
  whose default host is `https://api.celerbrake.com`.
- The Rails generator now reads `CELERBRAKE_PROJECT_ID` / `CELERBRAKE_PROJECT_KEY`
  and writes a `config/initializers/celerbrake.rb`.
- Otherwise wire-compatible with the Airbrake v3 `create-notice` API; all the
  framework integrations (Rails, Sidekiq, Resque, Delayed Job, ActiveJob,
  Shoryuken, Sneakers, ...) are preserved.

For the full history of the upstream gem prior to the fork, see the
[airbrake CHANGELOG][upstream-changelog].

[airbrake]: https://github.com/airbrake/airbrake
[celerbrake-ruby]: https://github.com/celerbrake/celerbrake-ruby
[upstream-changelog]: https://github.com/airbrake/airbrake/blob/master/CHANGELOG.md
