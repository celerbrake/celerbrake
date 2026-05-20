# frozen_string_literal: true

module Celerbrake
  module Rack
    # Celerbrake Rack middleware for Rails and Sinatra applications (or any other
    # Rack-compliant app). Any errors raised by the upstream application will be
    # delivered to Celerbrake and re-raised.
    #
    # The middleware automatically sends information about the framework that
    # uses it (name and version).
    #
    # For Rails apps the middleware collects route performance statistics.
    class Middleware
      def initialize(app)
        @app = app
      end

      # Thread-safe {call!}.
      #
      # @param [Hash] env the Rack environment
      # @see https://github.com/celerbrake/celerbrake/issues/904
      def call(env)
        dup.call!(env)
      end

      # Rescues any exceptions, sends them to Celerbrake and re-raises the
      # exception. We also duplicate middleware to guarantee thread-safety.
      #
      # @param [Hash] env the Rack environment
      def call!(env)
        before_call(env)

        begin
          response = @app.call(env)
        rescue Exception => ex # rubocop:disable Lint/RescueException
          notify_celerbrake(ex)
          raise ex
        end

        exception = framework_exception(env)
        notify_celerbrake(exception) if exception

        response
      ensure
        # Clear routes for the next request.
        RequestStore.clear
      end

      private

      def before_call(env)
        # Rails hooks such as ActionControllerRouteSubscriber rely on this.
        RequestStore[:routes] = {}
        RequestStore[:request] = find_request(env)
      end

      def find_request(env)
        if defined?(ActionDispatch::Request)
          ActionDispatch::Request.new(env)
        elsif defined?(Sinatra::Request)
          Sinatra::Request.new(env)
        else
          ::Rack::Request.new(env)
        end
      end

      def notify_celerbrake(exception)
        notice = Celerbrake.build_notice(exception)
        return unless notice

        # ActionDispatch::Request correctly captures server port when using SSL:
        # See: https://github.com/celerbrake/celerbrake/issues/802
        notice.stash[:rack_request] = RequestStore[:request]

        Celerbrake.notify(notice)
      end

      # Web framework middlewares often store rescued exceptions inside the
      # Rack env, but Rack doesn't have a standard key for it:
      #
      # - Rails uses action_dispatch.exception: https://goo.gl/Kd694n
      # - Sinatra uses sinatra.error: https://goo.gl/LLkVL9
      # - Goliath uses rack.exception: https://goo.gl/i7e1nA
      def framework_exception(env)
        env['action_dispatch.exception'] ||
          env['sinatra.error'] ||
          env['rack.exception']
      end
    end
  end
end

[
  Celerbrake::Rack::ContextFilter,
  Celerbrake::Rack::UserFilter,
  Celerbrake::Rack::SessionFilter,
  Celerbrake::Rack::HttpParamsFilter,
  Celerbrake::Rack::HttpHeadersFilter,
  Celerbrake::Rack::RouteFilter,
].each do |filter|
  Celerbrake.add_filter(filter.new)
end
