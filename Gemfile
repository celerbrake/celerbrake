source 'https://rubygems.org'
gemspec

# celerbrake-ruby is developed alongside this gem and not yet published. Use the
# sibling checkout when it's present (local dev); otherwise resolve it from
# GitHub so `bundle install` works in CI and fresh clones. Once celerbrake-ruby
# is on RubyGems, drop this block — the gemspec dependency (~> 0.1) is enough.
celerbrake_ruby_path = File.expand_path('../celerbrake-ruby', __dir__)
if File.directory?(celerbrake_ruby_path)
  gem 'celerbrake-ruby', path: celerbrake_ruby_path
else
  gem 'celerbrake-ruby',
      git: 'https://github.com/celerbrake/celerbrake-ruby.git',
      branch: 'main'
end

# Pinned to a patch range on purpose. `.rubocop.yml` used to run an
# unpinned rubocop with `NewCops: enable`, so any rubocop release could
# turn this build red without a line changing here. That is exactly how CI
# went red on 2026-05-20 and stayed red. A bump is now a deliberate act
# (dependabot opens the PR), not a surprise.
gem 'rubocop', '~> 1.91.0', require: false
gem 'sneakers', github: 'jondot/sneakers', ref: '31d0cb25dc5bbcfb0749567e9e0f80e6353fb66b'
