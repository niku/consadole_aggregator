require 'consadole_aggregator'
require 'tempfile'

module ConsadoleAggregator::News
  describe Store do
    subject { described_class.new(store, name) }
    let(:store) { PStore.new(Tempfile.open('store'), true) }
    let(:name) { 'a-store' }
    let(:new_item) { 'new item' }
    let(:stored_value) { 'stored value' }

    describe '.store_path' do
      it { expect(described_class.store_path).to end_with 'pstore' }
    end

    describe '.load' do
      it 'should call :new with kind of PStore and name' do
        Store.should_receive(:new).with(kind_of(PStore), name)
        Store.load(name)
      end
    end

    context 'when data does not exist' do
      describe '#member?' do
        it { expect(subject.member?(new_item)).to be_false }
      end

      describe '#add_if_new_item' do
        it 'should increase count' do
          expect {
            subject.add_if_new_item(new_item)
          }.to change { subject.count }.from(0).to(1)
        end

        it 'should sync to store' do
          subject.add_if_new_item(new_item)
          expect(store.transaction {|s| s.fetch(name, []) }).to eq [new_item]
        end
      end
    end

    context 'when a data exists' do
      let(:store) {
        pstore = super()
        pstore.transaction {|s| s[name] = [stored_value] }
        pstore
      }

      describe '#member?' do
        it { expect(subject.member?(stored_value)).to be_true }
        it { expect(subject.member?(new_item)).to be_false }
      end

      describe '#add_if_new_item' do
        context 'given new item without block' do
          it 'should increase count' do
            expect {
              subject.add_if_new_item(new_item)
            }.to change { subject.count }.from(1).to(2)
          end

          it 'should sync to store' do
            subject.add_if_new_item(new_item)
            expect(store.transaction {|s| s.fetch(name, []) }).to eq [stored_value,
                                                                      new_item]
          end
        end

        context 'given stored item without block' do
          it 'should not increase count' do
            expect {
              subject.add_if_new_item(stored_value)
            }.to_not change { subject.count }
          end

          it 'should sync to store' do
            subject.add_if_new_item(stored_value)
            expect(store.transaction {|s| s.fetch(name, []) }).to eq [stored_value]
          end
        end

        context 'given stored item with block' do
          it 'should not yield block' do
            expect {|block|
              subject.add_if_new_item(stored_value, &block)
            }.to_not yield_control
          end
        end

        context 'given new item with block' do
          it 'should yield block with the value' do
            expect {|block|
              subject.add_if_new_item(new_item, &block)
            }.to yield_with_args(new_item)
          end

          describe 'does not raise error' do
            it 'should add value' do
              expect {
                subject.add_if_new_item(new_item) {|v| v }
              }.to change { subject.count }.by(1)
            end
          end

          describe 'raise error' do
            it 'should add value' do
              expect {
                subject.add_if_new_item(new_item) {|v| raise }
              }.to_not change { subject.count }
            end
          end
        end
      end
    end
  end
end
