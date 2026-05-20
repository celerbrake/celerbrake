# frozen_string_literal: true

module Celerbrake
  # The Capistrano v2 integration.
  module Capistrano
    # rubocop:disable Metrics/AbcSize
    def self.load_into(config)
      config.load do
        after 'deploy',            'celerbrake:deploy'
        after 'deploy:migrations', 'celerbrake:deploy'
        after 'deploy:cold',       'celerbrake:deploy'

        namespace :celerbrake do
          desc "Notify Celerbrake of the deploy"
          task :deploy, except: { no_release: true }, on_error: :continue do
            run(
              <<-CMD, once: true
                cd #{config.release_path} && \

                RACK_ENV=#{fetch(:rack_env, nil)} \
                RAILS_ENV=#{fetch(:rails_env, nil)} \

                bundle exec rake celerbrake:deploy \
                  USERNAME=#{Shellwords.shellescape(ENV.fetch('USER', nil) || ENV.fetch('USERNAME', nil))} \
                  ENVIRONMENT=#{fetch(:celerbrake_env, fetch(:rails_env, 'production'))} \
                  REVISION=#{current_revision.strip} \
                  REPOSITORY=#{repository} \
                  VERSION=#{fetch(:app_version, nil)}
              CMD
            )
            logger.info 'Notified Celerbrake of the deploy'
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end

Celerbrake::Capistrano.load_into(Capistrano::Configuration.instance)
