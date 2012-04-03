# -*- coding: utf-8 -*-
require 'spec_helper'

module ConsadoleAggregator
  describe Aggregatable do
    before do
      @articles = [{ url:'http://example.jp/',  title:'hoge' },
                   { url:'http://example.com/', title:'fuga' }]
      get_resource_stub = double('get_resource')
      get_resource_stub.stub(:call).and_return('')
      parse_list_stub = double('parse_list')
      parse_list_stub.stub(:call).and_return(['http://example.jp/', 'http://example.com/'])
      parse_article_stub = double('parse_article')
      parse_article_stub.stub(:call) do |arg|
        if arg == 'http://example.jp/'
          { url:arg, title:'hoge' }
        else
          { url:arg, title:'fuga' }
        end
      end
      klass = Class.new do
        include Aggregatable
        @get_resource  = get_resource_stub
        @parse_list    = parse_list_stub
        @parse_article = parse_article_stub
      end
      ConsadoleAggregator::News.const_set(:TestClass, klass) # FIXME How do I suppress warning?
      subject.stub(:save_strage)
    end

    subject{ News::TestClass.new }

    describe '#get_new_articles' do
      context 'when article straged' do
        before do
          @straged = [@articles.first]
          subject.stub!(:get_strage).and_return(@straged)
        end
        it 'should return part of articles' do
          subject.get_new_articles.should == @articles - @straged
        end
      end
    end

    describe '#update' do
      context 'when default' do
        it 'should call ordered' do
          subject.should_receive(:get_new_articles).ordered.and_return([])
          subject.should_receive(:save_strage).ordered
          subject.update
        end
      end
      context 'when new_articles exist' do
        before do
          YAML.stub!(:load_file).and_return([])
          subject.stub!(:get_new_articles).and_return(@articles)
        end
        it 'should add strage' do
          expect{ subject.update }.to change{ subject.get_strage.dup }.from([]).to(@articles)
        end
      end
    end

    describe '#get_strage' do
      context 'when yaml can load' do
        it 'should load from yaml' do
          YAML.should_receive(:load_file).with(/\/db\/TestClass.yaml$/)
          subject.get_strage
        end
      end
      context 'when yaml can\'t load' do
        before do
          YAML.stub!(:load_file){ raise }
        end
        it 'should load from yaml' do
          pending
          except{ subject.get_strage }.to should_raise
        end
      end
    end

    describe '#build_strage_path' do
      context 'when Testclass' do
        it { subject.build_strage_path.should match /\/db\/TestClass.yaml$/ }
      end
    end
  end
end
