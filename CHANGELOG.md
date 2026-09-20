Celerbrake Changelog
====================

### master

- **CI is green again, and it now covers Rails 8.** Every Rails integration
  suite had been failing with the same 27 errors since json 3.0: ActiveSupport
  below 8.1 encodes with
  `JSON.generate(jsonified, quirks_mode: true, max_nesting: false)` and json 3
  removed `quirks_mode`, so `Notice#to_json` raised inside the sender thread
  and no notice ever reached the wire. json is pinned below 3 in the
  appraisals where ActiveSupport still passes the keyword. This was never a
  runtime defect for the fleet, which runs Rails 8.1 on json 2.x.
- **Appraisals now span Rails 6.1 to 8.0.** 7.1, 7.2 and 8.0 added; 5.2 and
  6.0 dropped as EOL. Until now the newest framework tested was Rails 7.0,
  while the fleet ran 8.1.
- **Ruby 2.6, 2.7 and JRuby dropped from CI; 3.2, 3.3 and 3.4 added.** JRuby
  could not even load `spec_helper` (`rbtree-jruby` 0.2 is a Java extension
  JRuby 10.1 refuses), and nothing in the fleet runs it.
  `required_ruby_version` is now `>= 3.0` so the gemspec claims only what CI
  exercises.
- **RuboCop is deterministic.** Pinned to a patch range with
  `NewCops: disable`, so a rubocop release can no longer turn this build red
  with no line changing here. The 14 real offences that had accumulated are
  fixed rather than excluded (`each_key` / `each_value` for hash iteration, a
  redundant self-assignment, a redundant `freeze` on a Regexp literal,
  line lengths, two stale cop directives).
- The Rails query-performance spec no longer pins `func` to the literal
  `"call"`: Ruby 3.4 qualifies a backtrace label with its owner.

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
