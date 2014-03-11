require 'consadole_aggregator'

module ConsadoleAggregator::News
  describe Fetcher do
    subject {
      m = described_class
      Class.new { |c| c.include(m) }.new(name, logger)
    }
    let(:name) { 'Foo' }
    let(:logger) { Logger.new(IO::NULL) }

    context 'when initialized' do
      describe '#fetch_resource' do
        it { expect(subject).to respond_to(:fetch_resource) }
      end

      describe '#invoke' do
        it { expect(subject).to respond_to(:invoke) }
        it 'should force encoding document'
        it 'should encode document'
      end
    end
  end

  describe HTTPFetcher do
    subject { described_class.new(name, logger) }
    let(:name) { 'Foo' }
    let(:logger) { Logger.new(IO::NULL) }

    context 'when initialized' do
      describe '#fetch_resource' do
        it 'Net::HTTP should receive get with path' do
          path = URI.parse('http://example.com')
          expect(Net::HTTP).to receive(:get) { path }
          subject.fetch_resource path
        end

        it 'Net::HTTP should receive get with canonicalized_path' do
          path = 'http://example.com'
          expect(Net::HTTP).to receive(:get) { URI.parse(path) }
          subject.fetch_resource path
        end
      end
    end
  end
end
