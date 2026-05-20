# frozen_string_literal: true

require 'celerbrake/rails/railtie'

module Celerbrake
  # Rails namespace holds all Rails-related functionality.
  module Rails
    def self.logger
      # Rails.logger is not set in some Rake tasks such as
      # 'celerbrake:deploy'. In this case we use a sensible fallback.
      level = (::Rails.logger ? ::Rails.logger.level : Logger::ERROR)

      if ENV['RAILS_LOG_TO_STDOUT'].present?
        Logger.new($stdout, level: level)
      else
        Logger.new(::Rails.root.join('log', 'celerbrake.log'), level: level)
      end
    end
  end
end

if defined?(ActionController::Metal)
  require 'celerbrake/rails/action_controller'
  module ActionController
    # Adds support for Rails API/Metal for Rails < 5. Rails 5+ uses standard
    # hooks.
    # @see https://github.com/celerbrake/celerbrake/issues/821
    class Metal
      include Celerbrake::Rails::ActionController
    end
  end
end
