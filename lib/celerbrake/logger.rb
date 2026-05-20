# frozen_string_literal: true

require 'logger'
require 'delegate'

module Celerbrake
  # Decorator for +Logger+ from stdlib. Endows loggers the ability to both log
  # and report errors to Celerbrake.
  #
  # @example
  #   # Create a logger like you normally do and decorate it.
  #   logger = Celerbrake::CelerbrakeLogger.new(Logger.new($stdout))
  #
  #   # Just use the logger like you normally do.
  #   logger.fatal('oops')
  class CelerbrakeLogger < SimpleDelegator
    # @example
    #   # Assign a custom Celerbrake notifier
    #   logger.celerbrake_notifier = Celerbrake::NoticeNotifier.new
    # @return [Celerbrake::Notifier] notifier to be used to send notices
    attr_accessor :celerbrake_notifier

    # @return [Integer]
    attr_reader :celerbrake_level

    def initialize(logger)
      super

      __setobj__(logger)
      @celerbrake_notifier = Celerbrake
      self.level = logger.level
    end

    # @see Logger#warn
    def warn(progname = nil, &block)
      notify_celerbrake(Logger::WARN, progname)
      super
    end

    # @see Logger#error
    def error(progname = nil, &block)
      notify_celerbrake(Logger::ERROR, progname)
      super
    end

    # @see Logger#fatal
    def fatal(progname = nil, &block)
      notify_celerbrake(Logger::FATAL, progname)
      super
    end

    # @see Logger#unknown
    def unknown(progname = nil, &block)
      notify_celerbrake(Logger::UNKNOWN, progname)
      super
    end

    # @see Logger#level=
    def level=(value)
      self.celerbrake_level = value < Logger::WARN ? Logger::WARN : value
      super
    end

    # Sets celerbrake severity level. Does not permit values below `Logger::WARN`.
    #
    # @example
    #   logger.celerbrake_level = Logger::FATAL
    # @return [void]
    def celerbrake_level=(level)
      if level < Logger::WARN
        raise "Celerbrake severity level #{level} is not allowed. " \
              "Minimum allowed level is #{Logger::WARN}"
      end
      @celerbrake_level = level
    end

    private

    def notify_celerbrake(severity, progname)
      return if severity < @celerbrake_level || !@celerbrake_notifier

      @celerbrake_notifier.notify(progname) do |notice|
        # Get rid of unwanted internal Logger frames. Examples:
        # * /ruby-2.4.0/lib/ruby/2.4.0/logger.rb
        # * /gems/activesupport-4.2.7.1/lib/active_support/logger.rb
        backtrace = notice[:errors].first[:backtrace]
        notice[:errors].first[:backtrace] =
          backtrace.drop_while { |frame| frame[:file] =~ %r{/logger.rb\z} }

        notice[:context][:component] = 'log'
        notice[:context][:severity] = normalize_severity(severity)
      end
    end

    def normalize_severity(severity)
      (case severity
       when Logger::WARN then 'warning'
       when Logger::ERROR, Logger::UNKNOWN then 'error'
       when Logger::FATAL then 'critical'
       else
         raise "Unknown celerbrake severity: #{severity}"
       end).freeze
    end
  end
end
