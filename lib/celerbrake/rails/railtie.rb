# frozen_string_literal: true

module Celerbrake
  module Rails
    # This railtie works for any Rails application that supports railties (Rails
    # 3.2+ apps). It makes Celerbrake Ruby work with Rails and report errors
    # occurring in the application automatically.
    class Railtie < ::Rails::Railtie
      initializer('celerbrake.middleware') do |app|
        require 'celerbrake/rails/railties/middleware_tie'
        Railties::MiddlewareTie.new(app).call
      end

      rake_tasks do
        # Report exceptions occurring in Rake tasks.
        require 'celerbrake/rake'

        # Defines tasks such as `celerbrake:test` & `celerbrake:deploy`.
        require 'celerbrake/rake/tasks'
      end

      initializer('celerbrake.action_controller') do
        require 'celerbrake/rails/railties/action_controller_tie'
        Railties::ActionControllerTie.new.call
      end

      initializer('celerbrake.active_record') do
        require 'celerbrake/rails/railties/active_record_tie'
        Railties::ActiveRecordTie.new.call
      end

      initializer('celerbrake.active_job') do
        ActiveSupport.on_load(:active_job, run_once: true) do
          # Reports exceptions occurring in ActiveJob jobs.
          require 'celerbrake/rails/active_job'
          include Celerbrake::Rails::ActiveJob
        end
      end

      initializer('celerbrake.action_cable') do
        ActiveSupport.on_load(:action_cable, run_once: true) do
          # Reports exceptions occurring in ActionCable connections.
          require 'celerbrake/rails/action_cable'
        end
      end

      runner do
        at_exit do
          Celerbrake.notify_sync($ERROR_INFO) if $ERROR_INFO
        end
      end
    end
  end
end
