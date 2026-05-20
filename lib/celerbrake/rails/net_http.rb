# frozen_string_literal: true

module Celerbrake
  module Rails
    # Monkey-patch Net::HTTP to benchmark it.
    # @api private
    # @since v10.0.2
    module NetHttp
      def request(request, *args, &block)
        Celerbrake::Rack.capture_timing(:http) do
          super(request, *args, &block)
        end
      end
    end
  end
end

Net::HTTP.prepend(Celerbrake::Rails::NetHttp)
