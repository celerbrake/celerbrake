# frozen_string_literal: true

require 'celerbrake/rails/action_controller_route_subscriber'

RSpec.describe Celerbrake::Rails::ActionControllerRouteSubscriber do
  describe "#call" do
    let(:app) { double(Celerbrake::Rails::App) }
    let(:event) { double(Celerbrake::Rails::Event) }

    let(:event_params) do
      [
        'start_processing.action_controller',
        Time.new,
        Time.new,
        '123',
        { method: 'HEAD', path: '/crash' },
      ]
    end

    before do
      allow(Celerbrake::Rails::App).to receive(:new).and_return(app)
      allow(Celerbrake::Rails::Event).to receive(:new).and_return(event)
    end

    context "when the Celerbrake config disables performance stats" do
      before do
        allow(Celerbrake::Config.instance)
          .to receive(:performance_stats).and_return(false)
      end

      it "doesn't store any routes in the request store under :routes" do
        subject.call(event_params)
        expect(Celerbrake::Rack::RequestStore[:routes]).to be_nil
      end
    end

    context "when request store has the :routes key" do
      before do
        allow(event).to receive(:method).and_return('HEAD')
        allow(event).to receive(:response_type).and_return(:html)

        Celerbrake::Rack::RequestStore[:routes] = {}
      end

      after { Celerbrake::Rack::RequestStore.clear }

      context "and when the route can be found" do
        before do
          allow(Celerbrake::Rails::App).to receive(:recognize_route).and_return(
            Celerbrake::Rails::App::Route.new('/crash'),
          )
        end

        it "stores a route in the request store under :routes" do
          subject.call(event_params)
          expect(Celerbrake::Rack::RequestStore[:routes])
            .to eq('/crash' => { method: 'HEAD', response_type: :html, groups: {} })
        end
      end

      context "and when the route can't be found" do
        before do
          allow(Celerbrake::Rails::App).to receive(:recognize_route).and_return(nil)
        end

        it "doesn't store any routes in the request store under :routes" do
          subject.call(event_params)
          expect(Celerbrake::Rack::RequestStore[:routes]).to be_empty
        end
      end
    end

    context "when request store doesn't have the :routes key" do
      before { Celerbrake::Rack::RequestStore.clear }

      it "doesn't store any routes in the request store" do
        subject.call(event_params)
        expect(Celerbrake::Rack::RequestStore[:routes]).to be_nil
      end
    end
  end
end
