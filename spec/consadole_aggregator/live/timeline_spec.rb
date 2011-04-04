# -*- coding: utf-8 -*-
require_relative '../../spec_helper'

include ConsadoleAggregator::Live

describe Timeline do
  describe '.parse' do
    context 'given nil' do
      subject{ Timeline.parse(nil) }
      it{ should be_nil }
    end
    context 'given ""' do
      subject{ Timeline.parse("") }
      it{ should be_nil }
    end
    context 'given "&lt;前半&gt;"' do
      subject{ Timeline.parse('&lt;前半&gt;') }
      it{ should be_nil }
    end
    context 'given "1分　右サイドからボールをつながれ攻撃を仕掛けられるが札幌DFが落ち着いてクリア"' do
      subject{ Timeline.parse('1分　右サイドからボールをつながれ攻撃を仕掛けられるが札幌DFが落ち着いてクリア') }
      it{ should eql Timeline.new('1分', '右サイドからボールをつながれ攻撃を仕掛けられるが札幌DFが落ち着いてクリア') }
    end
    context 'given "5分"' do
      subject{ Timeline.parse('5分') }
      it{ should eql Timeline.new('5分', nil) }
    end
  end
end
