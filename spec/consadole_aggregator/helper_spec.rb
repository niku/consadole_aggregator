# -*- coding: utf-8 -*-
require_relative '../spec_helper'

describe ConsadoleAggregator::Helper do
  describe :concatenate do
    context 'with argument 140 chars' do
      subject { ConsadoleAggregator::Helper.concat('い' * 140) }
      it { should have(140).item }
      it { should == 'い' * 140 }
    end
    context 'with argument 140 chars and 18 chars url' do
      subject { ConsadoleAggregator::Helper.concat('ろ' * 140, 'http://example.jp/') }
      it { should have(140).item }
      it { should be_end_with 'ろ... http://example.jp/' }
    end
    context 'with argument 140 chars and 10 chars hashtag' do
      subject { ConsadoleAggregator::Helper.concat('は' * 140, '', '#consadole') }
      it { should have(140).item }
      it { should be_end_with 'は... #consadole' }
    end
    context 'with argument 140 chars and 18 chars url and 10 chars hashtag' do
      subject { ConsadoleAggregator::Helper.concat('に' * 140, 'http://example.jp/', '#consadole') }
      it { should have(140).item }
      it { should be_end_with 'に... http://example.jp/ #consadole' }
    end
  end
end
