# frozen_string_literal: true

# ActiveSupport below 8.1 encodes JSON with
# `JSON.generate(jsonified, quirks_mode: true, max_nesting: false)`. The json
# gem removed `quirks_mode` in 3.0, so on those Rails versions every
# `to_json` raises `ArgumentError: unknown keyword: quirks_mode` the moment a
# notice is serialized. That is an ActiveSupport/json incompatibility, not a
# Celerbrake one (the fleet runs Rails 8.1 on json 2.x), but it took the
# Rails 6.0, 6.1 and 7.0 integration suites down with 27 identical failures
# each: the notice never reached the wire, so every "was expected to execute
# at least 1 time but it executed 0 times" expectation failed at once. Pin
# json where ActiveSupport still passes the keyword.
JSON_BELOW_3 = ['json', '< 3'].freeze

appraise 'rails-6.1' do
  gem 'rails', '~> 6.1.4.1'
  gem 'warden', '~> 1.2.6'
  gem 'rack', '~> 2.0'
  gem(*JSON_BELOW_3)

  gem 'sqlite3', '~> 1.4'

  gem 'resque', '~> 1.26'
  gem 'resque_spec', github: 'airbrake/resque_spec'

  gem 'delayed', '~> 0.4'

  gem 'mime-types', '~> 3.1'
end

appraise 'rails-7.0' do
  gem 'rails', '~> 7.0.1'
  gem 'warden', '~> 1.2.6'
  gem 'rack', '~> 2.0'
  gem(*JSON_BELOW_3)

  gem 'sqlite3', '~> 1.4'

  gem 'resque', '~> 1.26'
  gem 'resque_spec', github: 'airbrake/resque_spec'

  gem 'delayed', '~> 0.4'

  gem 'mime-types', '~> 3.1'
end

appraise 'rails-7.1' do
  gem 'rails', '~> 7.1.0'
  gem 'warden', '~> 1.2.6'
  gem 'rack', '~> 2.0'
  gem(*JSON_BELOW_3)

  gem 'sqlite3', '~> 1.4'

  gem 'resque', '~> 1.26'
  gem 'resque_spec', github: 'airbrake/resque_spec'

  gem 'delayed', '~> 0.4'

  gem 'mime-types', '~> 3.1'
end

appraise 'rails-7.2' do
  gem 'rails', '~> 7.2.0'
  gem 'warden', '~> 1.2.6'
  gem 'rack', '~> 2.0'
  gem(*JSON_BELOW_3)

  gem 'sqlite3', '~> 1.4'

  gem 'resque', '~> 1.26'
  gem 'resque_spec', github: 'airbrake/resque_spec'

  gem 'delayed', '~> 0.4'

  gem 'mime-types', '~> 3.1'
end

appraise 'rails-8.0' do
  gem 'rails', '~> 8.0.0'
  gem 'warden', '~> 1.2.6'
  gem 'rack', '~> 2.2'
  gem(*JSON_BELOW_3)

  # Rails 8 requires the sqlite3 2.x API.
  gem 'sqlite3', '~> 2.1'

  gem 'resque', '~> 1.26'
  gem 'resque_spec', github: 'airbrake/resque_spec'

  gem 'delayed', '~> 0.4'

  gem 'mime-types', '~> 3.1'
end

appraise 'sinatra' do
  gem 'sinatra', '~> 2'
  gem 'warden', '~> 1.2.6'
end

appraise 'rack' do
  gem 'warden', '~> 1.2.6'
end
