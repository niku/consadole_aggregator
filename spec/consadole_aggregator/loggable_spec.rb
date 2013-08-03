require 'consadole_aggregator'

module ConsadoleAggregator
  describe Loggable do
    subject {
      described_module = super()
      Class.new {|m| m.send(:include, described_module) }.new
    }

    context 'when logger was not setted' do
      describe '.logger=' do
        it { expect(subject).to be_respond_to(:logger=) }
      end

      describe '.debug' do
        # error, fatal, info, unknown and warn are same behavior as debug
        context 'given no block' do
          it { expect { subject.debug('foo') }.to raise_error }
        end

        context 'given block' do
          it { expect { subject.debug { 'foo' } }.not_to raise_error }
        end
      end
    end

    context 'when logger was setted' do
      before do
        subject.logger = logger
      end
      let(:logger) { double('logger') }

      describe '.debug' do
        # error, fatal, info, unknown and warn are same behavior as debug
        context 'given no block' do
          it { expect { subject.debug('foo') }.to raise_error }
        end

        context 'given block' do
          it {
            expect(logger).to receive(:debug)
            subject.debug { 'foo' }
          }
        end
      end
    end
  end
end
