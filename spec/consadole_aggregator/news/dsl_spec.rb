require 'consadole_aggregator'

module ConsadoleAggregator::News
  describe DSL do
    describe '.sites' do
      it { expect(described_class.sites).to be_a_kind_of(Enumerable) }
      it { expect {|b| described_class.sites &b }.to yield_with_args(DSL::Sites) }
      it 'should build sites' do
        sites = described_class.sites do |sites|
          sites.name(:foo) do |site|
            site.resource { open('http://example.com/foo') {|f| f.read } }
            site.list {|resource| resouce.scan(/href="[^"]"/).flatten }
            site.elements {|element| { url: element, path: element.split('/').last } }
          end
          sites.name(:bar) do |site|
            site.resource { open('http://example.com/bar') {|f| f.read } }
          end
        end
        expect(sites.count).to eq 2
      end
    end
  end

  describe DSL::Sites do
    context 'when initialized' do
      describe '#name' do
        it { expect {|b| subject.name(:foo, &b) }.to yield_with_args(DSL::Site) }
        it 'should increase site' do
          expect { subject.name(:foo) }.to change { subject.get.count }.from(0).to(1)
        end
      end

      describe '#get' do
        it { expect(subject.get).to eq [] }
      end
    end
  end

  describe DSL::Site do
    context 'when initialized' do
      subject { DSL::Site.new(source) }
      let(:source) { Source.new(:foo) }

      describe '#resource' do
        it 'should call Source#how_to_create_resource=' do
          expect(source).to receive(:how_to_create_resource=)
          subject.resource { '<html><body></body></html>' }
        end
      end

      describe '#list' do
        it 'should call Source#how_to_create_list=' do
          expect(source).to receive(:how_to_create_list=)
          subject.list {|resource| ['http://example.com/foo', 'http://example.com/bar'] }
        end
      end

      describe '#elements' do
        it 'should call Source#how_to_create_elements=' do
          expect(source).to receive(:how_to_create_elements=)
          subject.elements {|element| { url:element, path:element.split('/').last } }
        end
      end
    end
  end
end
