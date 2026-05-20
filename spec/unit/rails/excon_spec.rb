# frozen_string_literal: true

require 'celerbrake/rails/excon_subscriber'

RSpec.describe Celerbrake::Rails::Excon do
  after { Celerbrake::Rack::RequestStore.clear }

  let(:event) { double(Celerbrake::Rails::Event) }

  before do
    allow(Celerbrake::Rails::Event).to receive(:new).and_return(event)
  end

  context "when there are no routes in the request store" do
    it "doesn't notify requests" do
      expect(Celerbrake).not_to receive(:notify_performance_breakdown)
      subject.call([])
    end
  end

  context "when there's a route in the request store" do
    let(:route) { Celerbrake::Rack::RequestStore[:routes]['/test-route'] }

    before do
      Celerbrake::Rack::RequestStore[:routes] = {
        '/test-route' => { groups: {} },
      }

      allow(event).to receive(:duration).and_return(0.1)
    end

    context "and when the Celerbrake config disables performance stats" do
      before do
        allow(Celerbrake::Config.instance)
          .to receive(:performance_stats).and_return(false)
      end

      it "doesn't set http group value of that route" do
        subject.call([])
        expect(route[:groups][:http]).to be_nil
      end
    end

    context "and when the Celerbrake config enables performance stats" do
      before do
        allow(Celerbrake::Config.instance)
          .to receive(:performance_stats).and_return(true)
      end

      it "sets http group value of that route" do
        subject.call([])
        expect(route[:groups][:http]).to eq(0.1)
      end

      context "and when the subscriber is called multiple times" do
        before { expect(event).to receive(:duration).and_return(0.1) }

        it "increments http group value of that route" do
          subject.call([])
          subject.call([])

          expect(route[:groups][:http]).to eq(0.2)
        end
      end
    end
  end
end
