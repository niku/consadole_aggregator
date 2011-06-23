# -*- coding: utf-8 -*-
require_relative '../spec_helper'

include ConsadoleAggregator

describe ConsadoleAggregator do
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
        it { expect{ subject.get_strage }.to raise_error }
      end
    end

    describe '#build_strage_path' do
      context 'when Testclass' do
        it { subject.build_strage_path.should match /\/db\/TestClass.yaml$/ }
      end
    end
  end

  describe News do
    before do
      ConsadoleAggregator::News::Nikkansports.get_resource =
        ->{ File.read('./spec/ext/nikkansports.txt').toutf8 }
      ConsadoleAggregator::News::Hochiyomiuri.get_resource =
        ->{ File.read('./spec/ext/hochiyomiuri.txt').toutf8 }
      ConsadoleAggregator::News::Asahi.get_resource =
        ->{ File.read('./spec/ext/asahi.txt').toutf8 }
      ConsadoleAggregator::News::Forzaconsadole.get_resource =
        ->{ File.read('./spec/ext/forzaconsadole.txt').toutf8 }
      ConsadoleAggregator::News::Consaburn.get_resource =
        ->{ File.read('./spec/ext/consaburn.txt').toutf8 }
      ConsadoleAggregator::News::Consaclub.get_resource =
        ->{ File.read('./spec/ext/consaclub.txt').toutf8 }
      ConsadoleAggregator::News::Consadolenews.get_resource =
        ->{ File.read('./spec/ext/consadolenews.txt').toutf8 }
      ConsadoleAggregator::News::Consadolephotos.get_resource =
        ->{ File.read('./spec/ext/consadolephotos.txt').toutf8 }
      ConsadoleAggregator::News::Jsgoalnews.get_resource =
        ->{ File.read('./spec/ext/jsgoalnews.txt').toutf8 }
      ConsadoleAggregator::News::Jsgoalphotos.get_resource =
        ->{ File.read('./spec/ext/jsgoalphotos.txt').toutf8 }
      ConsadoleAggregator::News::Clubconsadole.get_resource =
        ->{ File.read('./spec/ext/clubconsadole.txt').toutf8 }

      module News
        def self.trace(url_path, limit=nil)
          url_path
        end
      end
    end

    it 'Nikkansports should not raise Exception' do
      expect{ ConsadoleAggregator::News::Nikkansports.new.get_new_articles }.to_not raise_error
    end
    it 'Hochiyomiuri should not raise Exception' do
      expect{ ConsadoleAggregator::News::Hochiyomiuri.new.get_new_articles }.to_not raise_error
    end
    it 'Asahi should not raise Exception' do
      expect{ ConsadoleAggregator::News::Asahi.new.get_new_articles }.to_not raise_error
    end
    it 'Forzaconsadole should not raise Exception' do
      expect{ ConsadoleAggregator::News::Forzaconsadole.new.get_new_articles }.to_not raise_error
    end
    it 'Consaburn should not raise Exception' do
      expect{ ConsadoleAggregator::News::Consaburn.new.get_new_articles }.to_not raise_error
    end
    it 'Consaclub should not raise Exception' do
      expect{ ConsadoleAggregator::News::Consaclub.new.get_new_articles }.to_not raise_error
    end
    describe ConsadoleAggregator::News::Consadolenews do
      subject{ ConsadoleAggregator::News::Consadolenews.new }
      it 'Consadolenews should not raise Exception' do
        expect{ subject.get_new_articles }.to_not raise_error
      end
      it{ subject.get_new_articles.should have_at_least(1).items }
    end
    describe ConsadoleAggregator::News::Consadolephotos do
      subject{ ConsadoleAggregator::News::Consadolephotos.new }
      it 'Consadolephotos should not raise Exception' do
        expect{ subject.get_new_articles }.to_not raise_error
      end
      it{ subject.get_new_articles.should have_at_least(1).items }
    end
    it 'Jsgoalnews should not raise Exception' do
      expect{ ConsadoleAggregator::News::Jsgoalnews.new.get_new_articles }.to_not raise_error
    end
    it 'Jsgoalphotos should not raise Exception' do
      expect{ ConsadoleAggregator::News::Jsgoalphotos.new.get_new_articles }.to_not raise_error
    end
    describe ConsadoleAggregator::News::Clubconsadole do
      subject{ ConsadoleAggregator::News::Clubconsadole.new }
      it 'Clubconsadole should not raise Exception' do
        expect{ subject.get_new_articles }.to_not raise_error
      end
      it{ subject.get_new_articles.should have_at_least(1).items }
      it{ p subject.get_new_articles }
    end
  end
end
