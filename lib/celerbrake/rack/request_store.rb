# frozen_string_literal: true

module Celerbrake
  module Rack
    # RequestStore is a thin (and limited) wrapper around *Thread.current* that
    # allows writing and reading thread-local variables under the +:celerbrake+
    # key.
    # @api private
    # @since v8.1.3
    module RequestStore
      class << self
        # @return [Hash] a hash for all request-related data
        def store
          Thread.current[:celerbrake] ||= {}
        end

        # @return [void]
        def []=(key, value)
          store[key] = value
        end

        # @return [Object]
        def [](key)
          store[key]
        end

        # @return [void]
        def clear
          Thread.current[:celerbrake] = {}
        end
      end
    end
  end
end
