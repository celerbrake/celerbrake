# frozen_string_literal: true

require 'celerbrake/rails/event'
require 'celerbrake/rails/app'

module Celerbrake
  module Rails
    # ActionControllerRouteSubscriber sends route stat information, including
    # performance data.
    #
    # @since v8.0.0
    class ActionControllerRouteSubscriber
      def call(*args)
        return unless Celerbrake::Config.instance.performance_stats

        # We don't track routeless events.
        return unless (routes = Celerbrake::Rack::RequestStore[:routes])

        event = Celerbrake::Rails::Event.new(*args)
        route = Celerbrake::Rails::App.recognize_route(
          Celerbrake::Rack::RequestStore[:request],
        )
        return unless route

        routes[route.path] = {
          method: event.method,
          response_type: event.response_type,
          groups: {},
        }
      end
    end
  end
end
