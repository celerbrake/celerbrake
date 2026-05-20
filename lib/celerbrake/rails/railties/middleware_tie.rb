# frozen_string_literal: true

module Celerbrake
  module Rails
    module Railties
      # Ties Celerbrake Rails Middleware with Rails (error sending).
      #
      # Since Rails 3.2 the ActionDispatch::DebugExceptions middleware is
      # responsible for logging exceptions and showing a debugging page in case
      # the request is local. We want to insert our middleware after
      # DebugExceptions, so we don't notify Celerbrake about local requests.
      #
      # @api private
      # @since v13.0.1
      class MiddlewareTie
        def initialize(app)
          @app = app
          @middleware = app.config.middleware
        end

        def call
          return tie_rails_5_or_above if ::Rails.version.to_i >= 5

          if defined?(::ActiveRecord::ConnectionAdapters::ConnectionManagement)
            return tie_rails_4_or_below_with_active_record
          end

          tie_rails_4_or_below_with_active_record
        end

        private

        # Avoid the warning about deprecated strings.
        # Insert after DebugExceptions, since ConnectionManagement doesn't
        # exist in Rails 5 anymore.
        def tie_rails_5_or_above
          @middleware.insert_after(
            ActionDispatch::DebugExceptions,
            Celerbrake::Rack::Middleware,
          )
        end

        # Insert after ConnectionManagement to avoid DB connection leakage:
        # https://github.com/celerbrake/celerbrake/pull/568
        def tie_rails_4_or_below_with_active_record
          @middleware.insert_after(
            ::ActiveRecord::ConnectionAdapters::ConnectionManagement,
            'Celerbrake::Rack::Middleware',
          )
        end

        # Insert after DebugExceptions for apps without ActiveRecord.
        def tie_rails_4_or_below_without_active_record
          @middleware.insert_after(
            ActionDispatch::DebugExceptions,
            'Celerbrake::Rack::Middleware',
          )
        end
      end
    end
  end
end
