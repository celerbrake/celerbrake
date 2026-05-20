# frozen_string_literal: true

require 'celerbrake/rails/event'

module Celerbrake
  module Rails
    # @since v8.3.0
    class ActionControllerPerformanceBreakdownSubscriber
      def call(*args)
        return unless Celerbrake::Config.instance.performance_stats

        routes = Celerbrake::Rack::RequestStore[:routes]
        return if !routes || routes.none?

        event = Celerbrake::Rails::Event.new(*args)
        stash = build_stash

        routes.each do |route, params|
          groups = event.groups.merge(params[:groups])
          next if groups.none?

          breakdown_info = {
            method: event.method,
            route: route,
            response_type: event.response_type,
            groups: groups,
            timing: event.duration,
            time: event.time,
          }

          Celerbrake.notify_performance_breakdown(breakdown_info, stash)
        end
      end

      private

      def build_stash
        stash = {}
        request = Celerbrake::Rack::RequestStore[:request]
        return stash unless request

        stash[:request] = request
        if (user = Celerbrake::Rack::User.extract(request.env))
          stash.merge!(user.as_json)
        end

        stash
      end
    end
  end
end
