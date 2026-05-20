require './lib/celerbrake/version'

Gem::Specification.new do |s|
  s.name        = 'celerbrake'
  s.version     = Celerbrake::CELERBRAKE_VERSION.dup
  s.summary     = <<SUMMARY
Celerbrake provides self-hosted exception tracking for Ruby applications.
SUMMARY
  s.description = <<DESC
Celerbrake provides self-hosted, robust exception tracking for any Ruby
application. It lets you review errors, tie an error to an individual piece of
code, and trace the cause back to recent changes. The Celerbrake dashboard
provides easy categorization, searching, and prioritization of exceptions so
that when errors occur, your team can quickly determine the root cause.

This gem includes integrations with popular libraries and frameworks such as
Rails, Sinatra, Resque, Sidekiq, Delayed Job, Shoryuken, ActiveJob and many
more. It builds on the celerbrake-ruby notifier.

Celerbrake began as a fork of the airbrake gem
(https://github.com/airbrake/airbrake). It remains wire-compatible with the
Airbrake v3 notice API, but reports to a Celerbrake instance you control rather
than a third-party service.
DESC
  s.author      = 'Celerbrake'
  s.email       = 'support@celerbrake.com'
  s.homepage    = 'https://github.com/celerbrake/celerbrake'
  s.license     = 'MIT'

  s.require_path = 'lib'
  s.files        = ['lib/celerbrake.rb', *Dir.glob('lib/**/*')]

  s.required_ruby_version = '>= 2.6'

  s.metadata = {
    'rubygems_mfa_required' => 'true',
  }

  s.add_dependency 'celerbrake-ruby', '~> 0.1'

  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'rspec-wait', '~> 0'
  s.add_development_dependency 'rake', '~> 13'
  s.add_development_dependency 'pry', '~> 0'
  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'rack', '~> 2'
  s.add_development_dependency 'webmock', '~> 3'
  s.add_development_dependency 'amq-protocol'
  s.add_development_dependency 'rack-test', '~> 1.1'
  s.add_development_dependency 'redis', '~> 4.5'
  s.add_development_dependency 'sidekiq', '~> 6'
  s.add_development_dependency 'curb', '~> 1.0' if RUBY_ENGINE == 'ruby'
  s.add_development_dependency 'excon', '~> 0.64'
  s.add_development_dependency 'http', '~> 5.0'
  s.add_development_dependency 'httpclient', '~> 2.8'
  s.add_development_dependency 'typhoeus', '~> 1.3'

  # Fixes build failure with public_suffix v3
  # https://circleci.com/gh/celerbrake/celerbrake-ruby/889
  s.add_development_dependency 'public_suffix', '~> 4.0', '< 5.0'

  s.add_development_dependency 'redis-namespace', '~> 1.8'
end
