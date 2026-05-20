# frozen_string_literal: true

RSpec.describe Celerbrake::CelerbrakeLogger do
  let(:project_id) { 113743 }
  let(:project_key) { 'fd04e13d806a90f96614ad8e529b2822' }
  let(:endpoint) { "https://api.celerbrake.com/api/v3/projects/#{project_id}/notices" }
  let(:celerbrake) { Celerbrake::NoticeNotifier.new }
  let(:logger) { Logger.new('/dev/null') }

  subject { described_class.new(logger) }

  def wait_for_a_request_with_body(body)
    wait_for(a_request(:post, endpoint).with(body: body)).to have_been_made.once
  end

  before do
    stub_request(:post, endpoint).to_return(status: 201, body: '{}')
  end

  describe "#celerbrake_notifier" do
    it "installs Celerbrake notifier" do
      notifier_id = celerbrake.object_id
      expect(subject.celerbrake_notifier.object_id).not_to eq(notifier_id)

      subject.celerbrake_notifier = celerbrake
      expect(subject.celerbrake_notifier.object_id).to eq(notifier_id)
    end

    context "when Celerbrake is installed explicitly" do
      let(:out) { StringIO.new }
      let(:logger) { Logger.new(out) }

      before do
        subject.celerbrake_notifier = celerbrake
      end

      it "both logs and notifies" do
        msg = 'bingo'
        subject.fatal(msg)

        wait_for_a_request_with_body(/"message":"#{msg}"/)
        expect(out.string).to match(/FATAL -- : #{msg}/)
      end

      it "sets the correct severity" do
        subject.fatal('bango')
        wait_for_a_request_with_body(/"context":{.*"severity":"critical".*}/)
      end

      it "sets the correct component" do
        subject.fatal('bingo')
        wait_for_a_request_with_body(/"component":"log"/)
      end

      it "strips out internal logger frames" do
        subject.fatal('bongo')

        wait_for(
          a_request(:post, endpoint)
            .with(body: %r{"file":".+/logger.rb"}),
        ).not_to have_been_made
        wait_for(a_request(:post, endpoint)).to have_been_made.once
      end
    end

    context "when Celerbrake is not installed" do
      it "only logs, never notifies" do
        out = StringIO.new
        l = described_class.new(Logger.new(out))
        l.celerbrake_notifier = nil
        msg = 'bango'

        l.fatal(msg)

        wait_for(a_request(:post, endpoint)).not_to have_been_made
        expect(out.string).to match('FATAL -- : bango')
      end
    end
  end

  describe "#celerbrake_level" do
    context "when not set" do
      it "defaults to Logger::WARN" do
        expect(subject.celerbrake_level).to eq(Logger::WARN)
      end
    end

    context "when set" do
      before do
        subject.celerbrake_level = Logger::FATAL
      end

      it "does not notify below the specified level" do
        subject.error('bingo')
        wait_for(a_request(:post, endpoint)).not_to have_been_made
      end

      it "notifies in the current or above level" do
        subject.fatal('bingo')
        wait_for(a_request(:post, endpoint)).to have_been_made
      end

      it "raises error when below the allowed level" do
        expect do
          subject.celerbrake_level = Logger::DEBUG
        end.to raise_error(/severity level \d is not allowed/)
      end
    end
  end

  describe "#level=" do
    it "sets logger level" do
      subject.level = Logger::FATAL
      expect(subject.level).to eq(Logger::FATAL)
    end

    it "sets celerbrake level" do
      subject.level = Logger::FATAL
      expect(subject.celerbrake_level).to eq(Logger::FATAL)
    end

    it "normalizes celerbrake logger level when provided level is below WARN" do
      subject.level = Logger::DEBUG
      expect(subject.celerbrake_level).to eq(Logger::WARN)
    end
  end
end
