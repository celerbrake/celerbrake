# frozen_string_literal: true

module Celerbrake
  module Sneakers
    # Provides integration with Sneakers.
    #
    # @see https://github.com/jondot/sneakers
    # @since v7.2.0
    class ErrorReporter
      # @return [Array<Symbol>] ignored keys values of which raise
      #   SystemStackError when `as_json` is called on them
      # @see https://github.com/celerbrake/celerbrake/issues/850
      IGNORED_KEYS = %i[delivery_tag consumer channel].freeze

      # rubocop:disable Style/OptionalArguments
      def call(exception, worker = nil, context)
        # Later versions add a middle argument.
        Celerbrake.notify(exception, filter_context(context)) do |notice|
          notice[:context][:component] = 'sneakers'
          notice[:context][:action] = worker.class.to_s
        end
      end
      # rubocop:enable Style/OptionalArguments

      private

      def filter_context(context)
        return context unless context[:delivery_info]

        h = context.dup
        h[:delivery_info] = context[:delivery_info].reject do |k, _v|
          IGNORED_KEYS.include?(k)
        end
        h
      end
    end
  end
end

Sneakers.error_reporters << Celerbrake::Sneakers::ErrorReporter.new

module Celerbrake
  module Sneakers
    # @todo Migrate to Sneakers v2.12.0 middleware API when it's released
    # @see https://github.com/jondot/sneakers/pull/364
    module Worker
      # Sneakers v2.7.0+ renamed `do_work` to `process_work`.
      define_method(
        ::Sneakers::Worker.method_defined?(:process_work) ? :process_work : :do_work,
      ) do |delivery_info, metadata, msg, handler|
        timing = Celerbrake::Benchmark.measure do
          super(delivery_info, metadata, msg, handler)
        end
      rescue Exception => exception # rubocop:disable Lint/RescueException
        Celerbrake.notify_queue(
          queue: self.class.to_s,
          error_count: 1,
          timing: 0.01,
        )
        raise exception
      else
        Celerbrake.notify_queue(
          queue: self.class.to_s,
          error_count: 0,
          timing: timing,
        )
      end
    end
  end
end

Sneakers::Worker.prepend(Celerbrake::Sneakers::Worker)
