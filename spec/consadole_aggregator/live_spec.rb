# -*- coding: utf-8 -*-
require 'spec_helper'

include ConsadoleAggregator

describe ConsadoleAggregator do
  describe Live do
    describe '.get_resource' do
      it 'should exec Net::HTTP.get with Live::BASE_URI' do
        Net::HTTP.should_receive(:get)
          .with(URI.parse('http://www.consadole-sapporo.jp/view/s674.html'))
          .and_return(File.read(File.dirname(__FILE__) + '/../ext/live/s674.html'))
        Live::Live.get_resource.call
      end
    end

    describe '.parse_list' do
      context 'when start of game' do
        let(:resource){ File.read(File.dirname(__FILE__) + '/../ext/live/s674.html').toutf8 }
        let(:parsed_list){ Live::Live.parse_list.call(resource) }
        subject{ parsed_list }
        it{ should have(3).items }
      end
      context 'when end of game' do
        let(:resource){ File.read(File.dirname(__FILE__) + '/../ext/live/s674.html.120').toutf8 }
        let(:parsed_list){ Live::Live.parse_list.call(resource) }
        describe 'first TimeLine' do
          subject{ parsed_list.first }
          it{ should == '試合開始　札幌ボールでキックオフ' }
        end
        describe 'second TimeLine' do
          subject{ parsed_list[1] }
          it{ should == '1分　右サイドからボールをつながれ攻撃を仕掛けられるが札幌DFが落ち着いてクリア' }
        end
        describe 'last TimeLine' do
          subject{ parsed_list.last }
          it{ should == '試合終了　ロスタイムも余裕のプレーで相手の攻撃を許さず、3試合連続完封で3連勝を飾る' }
        end
      end
    end

    describe '.parse_article' do
      let(:article){ '1分　右サイドからボールをつながれ攻撃を仕掛けられるが札幌DFが落ち着いてクリア' }
      it{ Live::Live.parse_article.call(article) }
    end

    describe '.reserve' do
      context 'given Time' do
        it 'give constructor with Time ' do
          Live::Live.should_receive(:new).with(Time.parse('2011-02-14 13:00'), {})
          Live.reserve(Time.parse('2011-02-14 13:00'))
        end
      end
    end
  end

  describe Live::Live do
    describe '#execute' do
      before { Live.stub!(:get_resource).and_return(File.read(File.dirname(__FILE__) + '/../ext/live/s674.html.120').toutf8) }
      context 'when normal update' do
        subject{ Live::Live.new }
        it 'should to be be_daemonize' do
          subject.should_receive(:be_daemonize).ordered
          subject.should_receive(:wait_initial).ordered
          subject.should_receive(:update).ordered.exactly(240).times
          subject.should_receive(:sleep).with(30).exactly(240).times
          subject.execute
        end
      end
      context 'when raise Exception' do
        before do
          @live = Live::Live.new(nil, { times:1 })
          @live.stub!(:be_daemonize)
          @live.stub!(:wait_initial)
        end
        subject{ @live }
        it 'should log exception and sleep' do
          subject.should_receive(:sleep).once
          subject.execute{ |timeline| raise }
        end
      end
    end

    describe '#wait_initial' do
      context 'when reservation_time is nil' do
        subject{ Live::reserve }
        it 'not sleep' do
          subject.should_not_receive(:sleep)
          subject.wait_initial
        end
      end
      context 'given 10 hours later' do
        before { Time.stub!(:now).and_return(Time.parse('2011-03-05 04:00')) }
        subject{ Live.reserve(Time.parse('2011-03-05 14:00')) }
        it 'sleep 36000 sec' do
          subject.should_receive(:sleep).with(1.0*60*60*10)
          subject.wait_initial
        end
      end
      context 'given past time' do
        before { Time.stub!(:now).and_return(Time.parse('2011-03-05 14:01')) }
        subject{ Live.reserve(Time.parse('2011-03-05 14:00')) }
        it 'not sleep' do
          subject.should_receive(:sleep).with(0)
          subject.wait_initial
        end
      end
    end

    describe '#update' do
      before do
        @first_timeline =
          [
           Live::Timeline.parse('1分　右サイドからボールをつながれ攻撃を仕掛けられるが札幌DFが落ち着いてクリア'),
           Live::Timeline.parse('2分　左サイドキリノのパスカットから攻撃を仕掛けるがシュートまでは持ち込めず'),
           Live::Timeline.parse('3分　ゴール前ほぼ正面やや遠めのFKを上里が直接狙うが湘南DFの壁に当たる'),
          ]
      end
      context 'when first time' do
        before { Live.stub!(:parse).and_return(@first_timeline) }
        subject{ Live::Live.new }
        it{ expect{ subject.update }.to change{ subject.posted.dup }.from([]).to(@first_timeline) }
      end
      context 'when second time' do
        before do
          @second_timeline = @first_timeline.clone.push(Live::Timeline.parse('3分　右サイドからのクロスに阿部(湘南)がヘッドであわせるがGK高原がキャッチ'))
          Live.stub!(:parse).and_return(@first_timeline, @second_timeline)
          @live = Live::Live.new
          @live.update
        end
        subject{ @live }
        it { expect { subject.update }.to change{ subject.posted.dup }.from(@first_timeline).to(@second_timeline) }
      end
      context 'given block' do
        subject{ Live::Live.new }
        before do
          Live.stub!(:parse).and_return(@first_timeline)
          @ary = []
          subject.update { |timeline| @ary << timeline }
        end
        it { @ary.should == @first_timeline }
      end
    end
  end
end
