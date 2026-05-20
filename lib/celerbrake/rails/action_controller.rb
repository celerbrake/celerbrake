# frozen_string_literal: true

module Celerbrake
  module Rails
    # Contains helper methods that can be used inside Rails controllers to send
    # notices to Celerbrake. The main benefit of using them instead of the direct
    # API is that they automatically add information from the Rack environment
    # to notices.
    module ActionController
      private

      # A helper method for sending notices to Celerbrake *asynchronously*.
      # Attaches information from the Rack env.
      # @see Celerbrake#notify, #notify_celerbrake_sync
      def notify_celerbrake(exception, params = {}, &block)
        return unless (notice = build_notice(exception, params))

        Celerbrake.notify(notice, params, &block)
      end

      # A helper method for sending notices to Celerbrake *synchronously*.
      # Attaches information from the Rack env.
      # @see Celerbrake#notify_sync, #notify_celerbrake
      def notify_celerbrake_sync(exception, params = {}, &block)
        return unless (notice = build_notice(exception, params))

        Celerbrake.notify_sync(notice, params, &block)
      end

      # @param [Exception] exception
      # @return [Celerbrake::Notice] the notice with information from the Rack env
      def build_notice(exception, params = {})
        return unless (notice = Celerbrake.build_notice(exception, params))

        notice.stash[:rack_request] = request
        notice
      end
    end
  end
end
