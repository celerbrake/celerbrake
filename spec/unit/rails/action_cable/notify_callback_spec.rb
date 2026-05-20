# frozen_string_literal: true

require 'celerbrake/rails/action_cable/notify_callback'

RSpec.describe Celerbrake::Rails::ActionCable::NotifyCallback do
  describe ".call" do
    context "when block raises exception" do
      let(:channel) { double }
      let(:block) { proc { raise CelerbrakeTestError } }

      before do
        expect(channel).to receive(:channel_name).and_return('web_notifications')
      end

      it "notifies Celerbrake" do
        expect(Celerbrake).to(
          receive(:notify).with(an_instance_of(Celerbrake::Notice)),
        ) do |notice|
          expect(notice[:context][:component]).to eq('action_cable')
          expect(notice[:context][:action]).to eq('web_notifications')
        end

        expect { described_class.call(channel, block) }
          .to raise_error(CelerbrakeTestError)
      end
    end
  end
end
