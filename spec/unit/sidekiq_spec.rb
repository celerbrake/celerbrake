# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq/cli'
require 'celerbrake/sidekiq'

RSpec.describe Celerbrake::Sidekiq::ErrorHandler do
  let(:notices_endpoint) do
    'https://api.celerbrake.com/api/v3/projects/113743/notices'
  end

  let(:queues_endpoint) do
    'https://api.celerbrake.com/api/v5/projects/113743/queues-stats'
  end

  before do
    stub_request(:post, notices_endpoint).to_return(status: 201, body: '{}')
    stub_request(:put, queues_endpoint).to_return(status: 201, body: '{}')

    allow(Celerbrake).to receive(:notify)
    allow(Celerbrake).to receive(:notify_queue)
  end

  context "when the worker errors" do
    let(:exception) { RuntimeError.new('sidekiq error') }

    def call_handler
      subject.call(
        anything,
        { 'class' => 'HardSidekiqWorker', 'args' => %w[bango bongo] },
        'queue-name',
      ) do
        raise exception
      end
    rescue StandardError
      # Do nothing.
    end

    it "sends error" do
      expect(Celerbrake).to receive(:notify).with(
        exception,
        job: {
          'args' => %w[bango bongo],
          'class' => 'HardSidekiqWorker',
        },
      )
      call_handler
    end

    it "sends component & action" do
      expect(Celerbrake).to receive(:notify) do |notice|
        expect(notice[:context][:component]).to eq('sidekiq')
        expect(notice[:context][:action]).to eq('123')
      end
      call_handler
    end

    it "sends queue info with positive error count" do
      expect(Celerbrake).to receive(:notify_queue).with(
        queue: 'HardSidekiqWorker',
        error_count: 1,
        timing: 0.01,
      )
      call_handler
    end
  end

  context "when the worker finishes without an error" do
    def call_handler
      subject.call(
        anything,
        { 'class' => 'HardSidekiqWorker', 'args' => %w[bango bongo] },
        'queue-name',
      ) do
        # Do nothing.
      end
    end

    it "doesn't send a notice" do
      expect(Celerbrake).not_to receive(:notify)
    end

    it "sends a zero error count queue info with groups" do
      expect(Celerbrake).to receive(:notify_queue).with(
        queue: 'HardSidekiqWorker',
        error_count: 0,
        timing: an_instance_of(Float),
      )
      call_handler
    end
  end
end
