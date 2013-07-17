require 'consadole_aggregator'

module ConsadoleAggregator::News
  describe Source do
    subject { described_class.new(name) }
    let(:name) { :foo }

    context 'when initialized' do
      describe '#name' do
        it { expect(subject.name).to eq name }
      end

      describe '#create_resource' do
        it { expect(subject.create_resource).to eq [] }
      end

      describe '#create_list' do
        it { expect(subject.create_list).to eq [] }
      end

      describe '#get' do
        it { expect(subject.get).to eq [] }
      end
    end

    context 'when how_to_create_resource returns value' do
      subject {
        source = super()
        source.how_to_create_resource = -> { value }
        source
      }
      let(:value) {
        '<ul><li><a href="http://example.com/foo"></li><li><a href="http://example.com/bar"></li></ul>'
      }

      describe '#create_resource' do
        it 'should be equal the value' do
          expect(subject.create_resource).to eq value
        end
      end
    end

    context 'when how_to_create_resource raise error' do
      subject {
        source = super()
        source.how_to_create_resource = -> { raise }
        source
      }

      describe '#create_resource' do
        it 'should raise error' do
          expect { subject.create_resource }.to raise_error
        end
      end

      describe '#get' do
        it 'should return an empty array' do
          expect(subject.get).to eq []
        end
      end
    end

    context 'when how_to_create_list takes a resource and returns value' do
      subject {
        source = super()
        source.how_to_create_list = ->(resource) { resource.scan(/href="([^"]+)"/).flatten }
        source
      }

      describe '#create_list' do
        it 'should create list from resource' do
          subject.stub(:create_resource) {
            '<ul><li><a href="http://example.com/foo"></li><li><a href="http://example.com/bar"></li></ul>'
          }
          expect(subject.create_list).to eq ['http://example.com/foo',
                                             'http://example.com/bar']
        end
      end
    end

    context 'when how_to_create_list raise error' do
      subject {
        source = super()
        source.how_to_create_list = ->(resource) { raise }
        source
      }

      describe '#create_list' do
        it 'should raise error' do
          expect { subject.create_list }.to raise_error
        end
      end

      describe '#get' do
        it 'should return an empty array' do
          expect(subject.get).to eq []
        end
      end
    end

    context 'when how_to_create_elements takes an element and returns value' do
      subject {
        source = super()
        source.stub(:create_list) { ['http://example.com/foo', 'http://example.com/bar'] }
        source.how_to_create_elements = ->(element) { { url: element, title: element.split('/').last } }
        source
      }

      describe '#create_elements' do
        it 'should create elements from list' do
          expect(subject.create_elements).to eq [{ url: 'http://example.com/foo', title: 'foo' },
                                                 { url: 'http://example.com/bar', title: 'bar' }]
        end
      end
    end

    context 'when how_to_create_elements raise error at part of elements' do
      subject {
        source = super()
        source.stub(:create_list) { ['http://example.com/foo', 'http://example.com/bar'] }
        source.how_to_create_elements = ->(element) {
          if element == 'http://example.com/foo'
            raise
          else
            { url: element, title: element.split('/').last }
          end
        }
        source
      }

      describe '#create_elements' do
        it 'should create elements from a list' do
          expect(subject.create_elements).to eq [nil, { url: 'http://example.com/bar', title: 'bar' }]
        end
      end

      describe '#get' do
        it 'should return an array' do
          expect(subject.get).to eq [{ url: 'http://example.com/bar', title: 'bar' }]
        end
      end
    end

    context 'when how_to_create_elements raise error at all of elements' do
      subject {
        source = super()
        source.stub(:create_list) { ['http://example.com/foo', 'http://example.com/bar'] }
        source.how_to_create_elements = ->(element) { raise }
        source
      }

      describe '#create_elements' do
        it 'should return an array including nil' do
          expect(subject.create_elements).to eq [nil, nil]
        end
      end

      describe '#get' do
        it 'should return an empty array' do
          expect(subject.get).to eq []
        end
      end
    end
  end
end
