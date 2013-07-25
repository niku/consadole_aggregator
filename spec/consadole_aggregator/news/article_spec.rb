require 'consadole_aggregator'

module ConsadoleAggregator::News
  describe Article do
    context 'when initialized' do
      subject { described_class.new(url: url, title: title) }
      let(:url) { URI.parse('http://example.com/foo') }
      let(:title) { '_title' }

      describe '#url' do
        context 'given url as string' do
          let(:url) { 'http://example.com/foo' }
          it { expect(subject.url).to be_a_kind_of(URI) }
          it { expect(subject.url).to eq URI.parse(url) }
        end

        context 'given url as URI' do
          it { expect(subject.url).to eq url }
        end
      end

      describe '#title' do
        it { expect(subject.title).to eq title }
      end

      describe '#==' do
        it { expect(subject == described_class.new(url: url, title: title)).to be_true }
      end
    end
  end
end
