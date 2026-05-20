# frozen_string_literal: true

RSpec.describe Celerbrake::Rack::Middleware do
  # The list of Rack filters that read Rack request information and append it to
  # notices.
  [
    Celerbrake::Rack::ContextFilter,
    Celerbrake::Rack::UserFilter,
    Celerbrake::Rack::SessionFilter,
    Celerbrake::Rack::HttpParamsFilter,
    Celerbrake::Rack::HttpHeadersFilter,
    Celerbrake::Rack::RouteFilter,

    # Optional filters (must be included by users):
    # Celerbrake::Rack::RequestBodyFilter
  ].each do |filter|
    Celerbrake.add_filter(filter.new)
  end

  let(:app) { proc { |env| [200, env, 'Bingo bango content'] } }
  let(:faulty_app) { proc { raise CelerbrakeTestError } }
  let(:endpoint) { 'https://api.celerbrake.com/api/v3/projects/113743/notices' }
  let(:middleware) { described_class.new(app) }

  def env_for(url, opts = {})
    Rack::MockRequest.env_for(url, opts)
  end

  def wait_for_a_request_with_body(body)
    wait_for(a_request(:post, endpoint).with(body: body)).to have_been_made.once
  end

  before do
    stub_request(:post, endpoint).to_return(status: 201, body: '{}')
  end

  describe "#call" do
    context "when app raises an exception" do
      it "rescues the exception, notifies Celerbrake & re-raises it" do
        expect { described_class.new(faulty_app).call(env_for('/')) }
          .to raise_error(CelerbrakeTestError)

        wait_for_a_request_with_body(/"errors":\[{"type":"CelerbrakeTestError"/)
      end

      it "sends the notice with the Rack request attached" do
        expect(Celerbrake).to receive(:notify) do |notice|
          expect(notice.stash[:rack_request]).to be_a(Rack::Request)
        end

        expect { described_class.new(faulty_app).call(env_for('/')) }
          .to raise_error(CelerbrakeTestError)
      end

      it "sends framework version and name" do
        expect { described_class.new(faulty_app).call(env_for('/bingo/bango')) }
          .to raise_error(CelerbrakeTestError)

        wait_for_a_request_with_body(
          /"context":{.*"versions":{"(rails|sinatra|rack_version)"/,
        )
      end
    end

    context "when app doesn't raise" do
      context "and previous middleware stored an exception in env" do
        shared_examples 'stored exception' do |type|
          let(:env) { env_for('/').merge(type => CelerbrakeTestError.new) }

          it "notifies on #{type}, but doesn't raise" do
            described_class.new(app).call(env)
            wait_for_a_request_with_body(/"errors":\[{"type":"CelerbrakeTestError"/)
          end

          it "sends the notice with the Rack request attached" do
            expect(Celerbrake).to receive(:notify) do |notice|
              expect(notice.stash[:rack_request]).to be_a(Rack::Request)
            end
            described_class.new(app).call(env)
          end
        end

        ['rack.exception', 'action_dispatch.exception', 'sinatra.error'].each do |type|
          include_examples 'stored exception', type
        end
      end

      it "doesn't notify Celerbrake" do
        described_class.new(app).call(env_for('/'))
        sleep 1
        expect(a_request(:post, endpoint)).not_to have_been_made
      end
    end

    it "returns a response" do
      response =  described_class.new(app).call(env_for('/'))

      expect(response[0]).to eq(200)
      expect(response[1]).to be_a(Hash)
      expect(response[2]).to eq('Bingo bango content')
    end
  end

  context "when Celerbrake is not configured" do
    it "returns nil" do
      allow(Celerbrake).to receive(:build_notice).and_return(nil)
      allow(Celerbrake).to receive(:notify)

      expect { described_class.new(faulty_app).call(env_for('/')) }
        .to raise_error(CelerbrakeTestError)

      expect(Celerbrake).to have_received(:build_notice)
      expect(Celerbrake).not_to have_received(:notify)
    end
  end
end
