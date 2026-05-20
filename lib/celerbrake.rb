# frozen_string_literal: true

require 'shellwords'
require 'English'

# Core library that sends notices.
# See: https://github.com/celerbrake/celerbrake-ruby
require 'celerbrake-ruby'

require 'celerbrake/version'

# Automatically load needed files for the environment the library is running in.
if defined?(Rack)
  require 'celerbrake/rack'

  require 'celerbrake/rails' if defined?(Rails)
end

require 'celerbrake/rake' if defined?(Rake::Task)
require 'celerbrake/resque' if defined?(Resque)
require 'celerbrake/sidekiq' if defined?(Sidekiq)
require 'celerbrake/shoryuken' if defined?(Shoryuken)
require 'celerbrake/delayed_job' if defined?(Delayed)
require 'celerbrake/sneakers' if defined?(Sneakers)

require 'celerbrake/logger'

# Notify of unhandled exceptions, if there were any, but ignore SystemExit.
at_exit do
  Celerbrake.notify_sync($ERROR_INFO) if $ERROR_INFO
  Celerbrake.close
end
