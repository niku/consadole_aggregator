# -*- coding: utf-8 -*-
require_relative 'spec_helper'

module ConsadoleAggregator
  describe "ConsadoleAggregator" do
    it 'not be truncate 128 characters' do
      chars = 'a'.each_char.cycle.take(109).join
      url = 'http://example.jp/' # 18 characters
      "#{ConsadoleAggregator.truncate(chars, url)} #consadole".size.should == 139
      ConsadoleAggregator.truncate(chars, url).should_not =~ /a\.\.\. http:\/\/example\.jp\/$/
    end
    it 'not be truncate 129 characters' do
      chars = 'a'.each_char.cycle.take(110).join
      url = 'http://example.jp/' # 18 characters
      "#{ConsadoleAggregator.truncate(chars, url)} #consadole".size.should == 140
      ConsadoleAggregator.truncate(chars, url).should_not =~ /a\.\.\. http:\/\/example\.jp\/$/
    end
    it 'be truncate 130 characters' do
      chars = 'a'.each_char.cycle.take(111).join
      url = 'http://example.jp/' # 18 characters
      "#{ConsadoleAggregator.truncate(chars, url)} #consadole".size.should == 140
      ConsadoleAggregator.truncate(chars, url).should =~ /a\.\.\. http:\/\/example\.jp\/$/
    end
    it 'be truncate 130 multibyte characters' do
      chars = 'あ'.each_char.cycle.take(111).join
      url = 'http://example.jp/' # 18 characters
      "#{ConsadoleAggregator.truncate(chars, url)} #consadole".size.should == 140
      ConsadoleAggregator.truncate(chars, url).should =~ /あ\.\.\. http:\/\/example\.jp\/$/
    end
    it 'be truncate 129 characters' do
      chars = 'a'.each_char.cycle.take(110).join
      url = 'http://example.jp/a' # 19 characters
      "#{ConsadoleAggregator.truncate(chars, url)} #consadole".size.should == 140
      ConsadoleAggregator.truncate(chars, url).should =~ /a\.\.\. http:\/\/example\.jp\/a$/
    end
    it 'not be truncate 129 characters without url' do
      chars = 'a'.each_char.cycle.take(129).join
      "#{ConsadoleAggregator.truncate(chars)} #consadole".size.should == 140
    end
    it 'not be truncate 130 characters without url' do
      chars = 'a'.each_char.cycle.take(130).join
      "#{ConsadoleAggregator.truncate(chars)} #consadole".size.should == 140
    end
  end
end
