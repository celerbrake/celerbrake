# frozen_string_literal: true

module Celerbrake
  module Rails
    # Monkey-patch to measure request timing.
    # @api private
    # @since v11.0.2
    module HTTP
      def perform(request, options)
        Celerbrake::Rack.capture_timing(:http) do
          super(request, options)
        end
      end
    end
  end
end

HTTP::Client.prepend(Celerbrake::Rails::HTTP)
