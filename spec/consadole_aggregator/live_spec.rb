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
      timelines = [TimeLine.new, TimeLine.new, TimeLine.new]
      ->{
        live.add_timeline(timelines[0])
      }.should change{ live.new_timeline(timelines) }.from(timelines).to(timelines[1..2])
    end
  end
end
