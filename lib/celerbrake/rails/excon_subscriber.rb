# frozen_string_literal: true

require 'celerbrake/rails/event'

module Celerbrake
  module Rails
    # @api private
    # @since v9.2.0
    class Excon
      def call(*args)
        return unless Celerbrake::Config.instance.performance_stats

        routes = Celerbrake::Rack::RequestStore[:routes]
        return if !routes || routes.none?

        event = Celerbrake::Rails::Event.new(*args)

        routes.each do |_route_path, params|
          params[:groups][:http] ||= 0
          params[:groups][:http] += event.duration
        end
      end
    end
  end
end
