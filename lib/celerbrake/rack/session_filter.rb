# frozen_string_literal: true

module Celerbrake
  module Rack
    # Adds HTTP session.
    #
    # @since v5.7.0
    class SessionFilter
      # @return [Integer]
      attr_reader :weight

      def initialize
        @weight = 96
      end

      # @see Celerbrake::FilterChain#refine
      def call(notice)
        return unless (request = notice.stash[:rack_request])

        session = request.session
        notice[:session] = session if session
      end
    end
  end
end
