# frozen_string_literal: true

require 'celerbrake/rails/action_controller_performance_breakdown_subscriber'

RSpec.describe Celerbrake::Rails::ActionControllerPerformanceBreakdownSubscriber do
  let(:app) { double(Celerbrake::Rails::App) }
  let(:event) { double(Celerbrake::Rails::Event) }

  before do
    allow(Celerbrake::Rails::Event).to receive(:new).and_return(event)
  end

  after { Celerbrake::Rack::RequestStore.clear }

  context "when routes are not set in the request store" do
    before { Celerbrake::Rack::RequestStore[:routes] = nil }

    it "doesn't send performance breakdown info" do
      expect(Celerbrake).not_to receive(:notify_performance_breakdown)
      subject.call([])
    end
  end

  context "when there are no routes in the request store" do
    before { Celerbrake::Rack::RequestStore[:routes] = {} }

    it "doesn't send performance breakdown info" do
      expect(Celerbrake).not_to receive(:notify_performance_breakdown)
      subject.call([])
    end
  end

  context "when there's a route in the request store" do
    before do
      allow(event).to receive(:groups).and_return(db: 0.5, view: 0.5)
      allow(event).to receive(:method).and_return('GET')
      allow(event).to receive(:response_type).and_return(:html)
      allow(event).to receive(:time).and_return(Time.new)
      allow(event).to receive(:duration).and_return(1.234)
    end

    context "when request store routes have extra groups" do
      before do
        Celerbrake::Rack::RequestStore[:routes] = {
          '/test-route' => {
            method: 'GET',
            response_type: :html,
            groups: { http: 0.5 },
          },
        }
      end

      context "and when the Celerbrake config enables performance stats" do
        before do
          allow(Celerbrake::Config.instance)
            .to receive(:performance_stats).and_return(true)
        end

        it "sends performance info to Celerbrake with extra groups" do
          expect(Celerbrake).to receive(:notify_performance_breakdown).with(
            hash_including(
              route: '/test-route',
              method: 'GET',
              response_type: :html,
              groups: { db: 0.5, view: 0.5, http: 0.5 },
            ),
            {},
          )
          subject.call([])
        end
      end

      context "and when the Celerbrake config disables performance stats" do
        before do
          allow(Celerbrake::Config.instance)
            .to receive(:performance_stats).and_return(false)
        end

        it "doesn't send performance info to Celerbrake" do
          expect(Celerbrake).not_to receive(:notify_performance_breakdown)
          subject.call([])
        end
      end
    end

    context "when there's a request in the request store" do
      let(:request) { instance_double('Rack::Request') }

      before do
        expect(request).to receive(:env).and_return({})
        Celerbrake::Rack::RequestStore[:request] = request

        Celerbrake::Rack::RequestStore[:routes] = {
          '/test-route' => { method: 'GET', response_type: :html, groups: {} },
        }
      end

      it "sends request info as metric stash" do
        expect(Celerbrake).to receive(:notify_performance_breakdown).with(
          an_instance_of(Hash),
          hash_including(request: request),
        )
        subject.call([])
      end

      context "and when a user can be found" do
        let(:user) { instance_double('User') }

        before do
          expect(Celerbrake::Rack::User).to receive(:extract).and_return(user)
          expect(user).to receive(:as_json).and_return(
            user: { 'id' => 1, 'name' => 'Arthur' },
          )
        end

        it "sends user info as metric stash" do
          expect(Celerbrake).to receive(:notify_performance_breakdown).with(
            an_instance_of(Hash),
            hash_including(user: { 'id' => 1, 'name' => 'Arthur' }),
          )
          subject.call([])
        end
      end
    end
  end
end
