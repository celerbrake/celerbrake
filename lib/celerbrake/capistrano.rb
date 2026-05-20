# frozen_string_literal: true

if defined?(Capistrano::VERSION) &&
   Gem::Version.new(Capistrano::VERSION).release >= Gem::Version.new('3.0.0')
  require 'celerbrake/capistrano/capistrano3'
else
  require 'celerbrake/capistrano/capistrano2'
end
