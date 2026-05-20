# frozen_string_literal: true

require 'celerbrake/rack/user'
require 'celerbrake/rack/user_filter'
require 'celerbrake/rack/context_filter'
require 'celerbrake/rack/session_filter'
require 'celerbrake/rack/http_params_filter'
require 'celerbrake/rack/http_headers_filter'
require 'celerbrake/rack/request_body_filter'
require 'celerbrake/rack/route_filter'
require 'celerbrake/rack/middleware'
require 'celerbrake/rack/request_store'
require 'celerbrake/rack/instrumentable'

module Celerbrake
  # Rack is a namespace for all Rack-related code.
  module Rack
    # @since v9.2.0
    # @api public
    def self.capture_timing(label)
      return yield unless Celerbrake::Config.instance.performance_stats

      routes = Celerbrake::Rack::RequestStore[:routes]
      if !routes || routes.none?
        result = yield
      else
        timed_trace = Celerbrake::TimedTrace.span(label) do
          result = yield
        end

        routes.each do |_route_path, params|
          params[:groups].merge!(timed_trace.spans)
        end
      end

      result
    end
  end
end
