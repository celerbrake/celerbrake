# frozen_string_literal: true

class SinatraTestApp < Sinatra::Base
  use Celerbrake::Rack::Middleware
  use Warden::Manager

  get '/' do
    'Hello from index'
  end

  get '/crash' do
    raise CelerbrakeTestError
  end
end
