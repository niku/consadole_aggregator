require 'consadole_aggregator'

module ConsadoleAggregator
  describe News do
    before do
      stub_const("ConsadoleAggregator::News::Sources", [source1, source2])
    end
    let(:source1) { double('source1', name: 's1') }
    let(:source2) { double('source2', name: 's2') }

    describe '.updaters' do
      it 'should translate from Souces to Updaters' do
        expect(subject.updaters).to eq [News::Updater.new(source1), News::Updater.new(source2)]
      end
    end

    describe '.update' do
      it 'should call Updater#invoke' do
        updater1 = double('updater1')
        updater2 = double('updater2')
        allow(subject).to receive(:updaters).and_return([updater1, updater2])

        expect(updater1).to receive(:invoke)
        expect(updater2).to receive(:invoke)
        subject.update
      end
    end
  end
end
