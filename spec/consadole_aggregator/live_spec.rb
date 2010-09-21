# -*- coding: utf-8 -*-
require_relative '../spec_helper'

module ConsadoleAggregator::Live
  describe 'ConsadoleAggregator::Live' do
    it 'parsed first time should 試合開始' do
      resource = File.new(File.dirname(__FILE__) + '/../ext/live/s674.html.120')
      Live.parse(resource).first.time.should == '試合開始'
    end
    it 'parsed second time should 1分' do
      resource = File.new(File.dirname(__FILE__) + '/../ext/live/s674.html.120')
      Live.parse(resource)[1].time.should == '1分'
    end
    it 'parsed second post should 右サイドからボールをつながれ攻撃を仕掛けられるが札幌DFが落ち着いてクリア' do
      resource = File.new(File.dirname(__FILE__) + '/../ext/live/s674.html.120')
      Live.parse(resource)[1].post.should == '右サイドからボールをつながれ攻撃を仕掛けられるが札幌DFが落ち着いてクリア'
    end
    it 'parsed last time should 試合終了' do
      resource = File.new(File.dirname(__FILE__) + '/../ext/live/s674.html.120')
      Live.parse(resource).last.time.should == '試合終了'
    end
    it 'sleeptime with argument Time' do
      Live.sleeptime(Time.parse'2999-12-31').should > 0
    end
    it 'sleeptime return 0 if minus' do
      Live.sleeptime(Time.now - 1000).should == 0
    end
    it 'sleeptime with exception returns 0' do
      Live.sleeptime(nil).should == 0
    end
    it 'add_timeline changes result of new_timline' do
      live = Live.new
      doc = '1分　右サイドからボールをつながれ攻撃を仕掛けられるが札幌DFが落ち着いてクリア'
      base_timeline = TimeLine.parse doc
      timelines =
        [
         TimeLine.parse(doc),
         TimeLine.parse('2分　左サイドキリノのパスカットから攻撃を仕掛けるがシュートまでは持ち込めず'),
         TimeLine.parse('3分　ゴール前ほぼ正面やや遠めのFKを上里が直接狙うが湘南DFの壁に当たる'),
        ]
      ->{
        live.add_timeline(base_timeline)
      }.should change{ live.new_timeline(timelines) }.from(timelines).to(timelines[1..2])
    end
    it '==, eql?, hash  should true' do
      doc = '1分　右サイドからボールをつながれ攻撃を仕掛けられるが札幌DFが落ち着いてクリア'
      TimeLine.parse(doc).should == TimeLine.parse(doc)
      TimeLine.parse(doc).eql?(TimeLine.parse(doc)).should be_true
      TimeLine.parse(doc).hash.should == TimeLine.parse(doc).hash
    end
  end
end
