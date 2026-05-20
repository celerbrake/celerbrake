# frozen_string_literal: true

module Celerbrake
  module Rails
    # Allow measuring request timing.
    module TyphoeusRequest
      def run
        Celerbrake::Rack.capture_timing(:http) do
          super
        end
      end
    end
  end
end

Typhoeus::Request.prepend(Celerbrake::Rails::TyphoeusRequest)
