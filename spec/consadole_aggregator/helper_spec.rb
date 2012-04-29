# -*- coding: utf-8 -*-
require 'spec_helper'

describe ConsadoleAggregator::Helper do
  describe '#truncate_for_twitter' do
    context 'with argument 140 chars' do
      subject { ConsadoleAggregator::Helper.truncate_for_twitter('い' * 140) }
      it { should have(140).item }
      it { should == 'い' * 140 }
    end
    context 'with argument 140 chars and 18 chars url' do
      subject { ConsadoleAggregator::Helper.truncate_for_twitter('ろ' * 140, url:'http://example.jp/') }
      it { should have(138).item }
      it { should be_end_with 'ろ... http://example.jp/' }
    end
    context 'with argument 140 chars and 10 chars hashtag' do
      subject { ConsadoleAggregator::Helper.truncate_for_twitter('は' * 140, hashtag:'#consadole') }
      it { should have(140).item }
      it { should be_end_with 'は... #consadole' }
    end
    context 'with argument 140 chars and 18 chars url and 10 chars hashtag' do
      subject { ConsadoleAggregator::Helper.truncate_for_twitter('に' * 140, url:'http://example.jp/', hashtag:'#consadole') }
      it { should have(138).item }
      it { should be_end_with 'に... http://example.jp/ #consadole' }
    end
    context 'with argument 140 chars and 29 chars url and 10 chars hashtag' do
      subject { ConsadoleAggregator::Helper.truncate_for_twitter('に' * 140, url:'http://example.jp/foo/bar/baz', hashtag:'#consadole') }
      it { should have(149).item }
      it { should be_end_with 'に... http://example.jp/foo/bar/baz #consadole' }
    end
  end
end
