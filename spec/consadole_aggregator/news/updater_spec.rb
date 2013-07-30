require 'consadole_aggregator'

module ConsadoleAggregator::News
  describe Updater do
    context 'when initialized' do
      subject { described_class.new(source) }
      let(:source) { double('source', name: source_name, get: source_articles) }
      let(:source_name) { :foo }
      let(:source_articles) { ['first article', 'second article'] }

      describe '#name' do
        it { expect(subject.name).to eq source_name }
      end

      describe '#articles' do
        it { expect(subject.articles).to eq source_articles }
      end

      describe '#store' do
        it 'should call Store.load with name' do
          expect(Store).to receive(:load).with(source_name)
          subject.store
        end
      end

      describe '#invoke' do
        it 'should call Store#add_if_not_member'do
          store = double('store')
          allow(subject).to receive(:store).and_return(store)
          # FIXME How to write to expect given block?
          expect(store).to receive(:add_if_not_member).with(source_articles[0]).and_yield('done!')
          expect(store).to receive(:add_if_not_member).with(source_articles[1]).and_yield('done!!')
          subject.invoke {|article| article }
        end
      end
    end
  end
end
