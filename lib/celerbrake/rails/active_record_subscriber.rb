# frozen_string_literal: true

require 'celerbrake/rails/event'
require 'celerbrake/rails/backtrace_cleaner'

module Celerbrake
  module Rails
    # ActiveRecordSubscriber sends SQL information, including performance data.
    #
    # @since v8.1.0
    class ActiveRecordSubscriber
      def call(*args)
        return unless Celerbrake::Config.instance.query_stats

        routes = Celerbrake::Rack::RequestStore[:routes]
        return if !routes || routes.none?

        event = Celerbrake::Rails::Event.new(*args)
        frame = last_caller

        routes.each do |route, params|
          Celerbrake.notify_query(
            route: route,
            method: params[:method],
            query: event.sql,
            func: frame[:function],
            file: frame[:file],
            line: frame[:line],
            timing: event.duration,
            time: event.time,
          )
        end
      end

      private

      def last_caller
        exception = StandardError.new
        exception.set_backtrace(
          Celerbrake::Rails::BacktraceCleaner.clean(Kernel.caller),
        )
        Celerbrake::Backtrace.parse(exception).first || {}
      end
    end
  end
end
