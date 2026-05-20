# frozen_string_literal: true

namespace :celerbrake do
  desc "Notify Celerbrake of the deploy"
  task :deploy do
    role = roles(:all, select: :primary).first || roles(:all).first
    on role do
      within release_path do
        with rails_env: fetch(:rails_env, fetch(:stage)) do
          execute :bundle, :exec, :rake, <<-CMD
            celerbrake:deploy USERNAME=#{Shellwords.shellescape(local_user)} \
                            ENVIRONMENT=#{fetch(:celerbrake_env, fetch(:rails_env, fetch(:stage)))} \
                            REVISION=#{fetch(:current_revision)} \
                            REPOSITORY=#{fetch(:repo_url)} \
                            VERSION=#{fetch(:app_version)}
          CMD

          info 'Notified Celerbrake of the deploy'
        end
      end
    end
  end
end
