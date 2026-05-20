# frozen_string_literal: true

require 'celerbrake/rails/action_cable/notify_callback'

%i[subscribe unsubscribe].each do |callback_name|
  ActionCable::Channel::Base.set_callback(
    callback_name, :around, prepend: true
  ) do |channel, inner|
    Celerbrake::Rails::ActionCable::NotifyCallback.call(channel, inner)
  end
end

module Celerbrake
  module ActionCable
    module Channel
      # @since v8.3.0
      # @api private
      # @see https://github.com/rails/rails/blob/master/actioncable/lib/action_cable/channel/base.rb
      module Base
        def perform_action(*args, &block)
          super(*args, &block)
        rescue Exception => ex # rubocop:disable Lint/RescueException
          Celerbrake.notify(ex) do |notice|
            notice.stash[:action_cable_connection] = connection
            notice[:context][:component] = self.class
            notice[:context][:action] = args.first['action']
            notice[:params].merge!(args.first)
          end

          raise ex
        end
      end
    end
  end
end

ActionCable::Channel::Base.prepend(Celerbrake::ActionCable::Channel::Base)
