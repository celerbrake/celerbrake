# frozen_string_literal: true

module Celerbrake
  module Rack
    # Adds current user information.
    #
    # @since v8.0.1
    class UserFilter
      # @return [Integer]
      attr_reader :weight

      def initialize
        @weight = 99
      end

      # @see Celerbrake::FilterChain#refine
      def call(notice)
        return unless (request = notice.stash[:rack_request])

        user = Celerbrake::Rack::User.extract(request.env)
        notice[:context].merge!(user.as_json) if user
      end
    end
  end
end
