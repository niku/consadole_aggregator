# -*- coding: utf-8 -*-
require_relative '../spec_helper'

module ConsadoleAggregator::Entry
  describe "ConsadoleAggregator::Entry" do
    before do
      Entry.all.destroy!
    end
    it "should create entry" do
      attributes = {
        uri:URI.parse('http://www.nikkansports.com/soccer/news/p-sc-tp0-20100611-640293.html'),
        title:'札幌の高校生ＦＷ三上が３戦連続先発へ - サッカーニュース'
      }
      lambda {
        Entry.create(attributes)
      }.should change { Entry.all.count }.from(0).to(1)
    end
    it "should select entry" do
      attributes = {
        uri:URI.parse('http://www.nikkansports.com/soccer/news/p-sc-tp0-20100611-640293.html'),
        title:'札幌の高校生ＦＷ三上が３戦連続先発へ - サッカーニュース'
      }
      id = Entry.create(attributes).id
      Entry.get(id).uri.to_s.should eql 'http://www.nikkansports.com/soccer/news/p-sc-tp0-20100611-640293.html'
    end
  end

  describe "List" do
    before do
      Entry.all.destroy!
      klass = Class.new do
        include List
        def initialize list
          @list = list
        end
      end
      doc = File.read(File.dirname(__FILE__) + '/../ext/consadole.rdf')
      list = RSS::Parser.parse(doc, false).items.map{ |e|
        Entry.new(uri:URI.parse(e.link), title:e.title)
      }.reverse
      @target = klass.new(list)
    end
    it "list should respond_to :each" do
      @target.list.should respond_to(:each)
    end
    it "list's element should respond_to :uri and :title" do
      @target.list.should be_all{ |e| e.respond_to?(:uri, :title) }
    end
    it "new_item should respond_to :each" do
      @target.new_items.should respond_to(:each)
    end
    it "new_item should diff of old_item" do
      old_list = @target.list
      old_list.drop(1).each{ |e| e.save }
      @target.new_items.first.uri.should eql old_list.first.uri
    end
  end

  describe "NikkanSports" do
    before do
      Entry.all.destroy!
      resource = File.new(File.dirname(__FILE__) + '/../ext/consadole.rdf')
      @nikkansports = NikkanSports.new resource
    end
    it "list's element should link of 'www.nikkansports.com/soccer/news/[f|p]-sc-tp0-dddddddd-dddddd.html'" do
      @nikkansports.list.should be_all{ |e|
        e.uri.host =~ /^www\.nikkansports\.com$/ && e.uri.path =~ /^\/soccer\/news\/[f|p]\-sc\-tp0\-\d{8}\-\d{6}\.html$/
      }
    end
  end

  describe "HochiYomiuri" do
    before do
      Entry.all.destroy!
      resource = File.new(File.dirname(__FILE__) + '/../ext/hochi_yomiuri.txt')
      @hochi_yomiuri = HochiYomiuri.new resource
    end
    it "list's element should link of 'hochi.yomiuri.co.jp/hokkaido/soccer/news/dddddddd-OHT1T00ddd.htm'" do
      @hochi_yomiuri.list.should be_all{ |e|
        e.uri.host =~ /^hochi\.yomiuri\.co\.jp$/ && e.uri.path =~ /^\/hokkaido\/soccer\/news\/\d{8}\-OHT1T00\d{3}\.htm$/
      }
    end
  end

  describe "Asahi" do
    before do
      Entry.all.destroy!
      resource = File.new(File.dirname(__FILE__) + '/../ext/asahi.txt')
      @asahi = Asahi.new resource
    end
    it "list's element should link of 'mytown.asahi.com/hokkaido/news.php'" do
      @asahi.list.should be_all{ |e|
        e.uri.host =~ /^mytown\.asahi\.com$/ && e.uri.path =~ /^\/hokkaido\/news\.php$/
      }
    end
  end

  describe "ForzaConsadole" do
    before do
      Entry.all.destroy!
      @forza_consadole = ForzaConsadole.new do
        def getResource
          File.new(File.dirname(__FILE__) + '/../ext/forza_consadole.txt')
        end
      end
    end
    it "list's element should link of 'www.hokkaido-np.co.jp/news/consadole/dddddd_all.html'" do
      @forza_consadole.list.should be_all{ |e|
        e.uri.host =~ /^www\.hokkaido\-np\.co\.jp$/ && e.uri.path =~ /^\/news\/consadole\/\d{6}_all\.html$/
      }
    end
  end

  describe "ConsaBurn" do
    before do
      Entry.all.destroy!
      @consa_burn = ConsaBurn.new do
        File.new(File.dirname(__FILE__) + '/../ext/consa_burn.txt')
      end
    end
    it "list's element should link of 'www.hokkaido-np.co.jp/cont/consa-burn/ddddd.html'" do
      @consa_burn.list.should be_all{ |e|
        e.uri.host =~ /^www\.hokkaido\-np\.co\.jp$/ && e.uri.path =~ /^\/cont\/consa\-burn\/\d+\.html$/
      }
    end
  end

  describe "ConsaClub" do
    before do
      Entry.all.destroy!
      @consa_club = ConsaClub.new do
        File.new(File.dirname(__FILE__) + '/../ext/consa_club.txt')
      end
    end
    it "list's element should link of 'www.hokkaido-np.co.jp/cont/consa-club/ddddd.html'" do
      @consa_club.list.should be_all{ |e|
        e.uri.host =~ /^www\.hokkaido\-np\.co\.jp$/ && e.uri.path =~ /^\/cont\/consa\-club\/\d+\.html$/
      }
    end
  end

  describe "ConsadoleNews" do
    before do
      Entry.all.destroy!
      doc = File.new(File.dirname(__FILE__) + '/../ext/consadole_news.txt')
      @consadole_news = ConsadoleNews.new doc
    end
    it "list's element should link of 'www.consadole-sapporo.jp/news/diary.cgi'" do
      @consadole_news.list.should be_all{ |e|
        e.uri.host =~ /^www\.consadole\-sapporo\.jp$/ && e.uri.path =~ /^\/news\/diary\.cgi$/
      }
    end
  end

  describe "ConsadoleSponsorNews" do
    before do
      Entry.all.destroy!
      doc = File.new(File.dirname(__FILE__) + '/../ext/consadole_sponsor_news.txt')
      @consadole_news = ConsadoleSponsorNews.new doc
    end
    it "list's element should link of 'www.consadole-sapporo.jp/snews/diary.cgi'" do
      @consadole_news.list.should be_all{ |e|
        e.uri.host =~ /^www\.consadole\-sapporo\.jp$/ && e.uri.path =~ /^\/snews\/diary\.cgi$/
      }
    end
  end

  describe "ConsadolePhotos" do
    before do
      Entry.all.destroy!
      doc = File.new(File.dirname(__FILE__) + '/../ext/consadole_photos.txt')
      @consadole_photos = ConsadolePhotos.new doc
    end
    it "list's element have 5 items" do
      @consadole_photos.list.should have(5).items
    end
    it "list's element should link of 'www.consadole-sapporo.jp/img/dd.jpg'" do
      @consadole_photos.list.should be_all{ |e|
        e.uri.host =~ /^www\.consadole\-sapporo\.jp$/ && e.uri.path =~ /^\/img\/\d\d\.jpg$/
      }
    end
    it "new_item size should diff of old_item" do
      old_list = @consadole_photos.list
      old_list.drop(1).each{ |e| e.save }
      @consadole_photos.new_items.should have(1).item
    end
    it "new_item title should diff of old_item" do
      old_list = @consadole_photos.list
      old_list.drop(1).each{ |e| e.save }
      @consadole_photos.new_items.first.title.should eql old_list.first.title
    end
  end

  describe "JsGoal" do
    before do
      Entry.all.destroy!
      klass = Class.new do
        include JsGoal
        def getResource
          File.new(File.dirname(__FILE__) + '/../ext/js_goal_news.txt')
        end
      end
      @target = klass.new
    end
    it "list's element have any size" do
      @target.list.should have_at_least(1).items
    end
  end

  describe "JsGoalNews" do
    before do
      Entry.all.destroy!
      @js_goal_news = JsGoalNews.new do
        def getResource
          File.new(File.dirname(__FILE__) + '/../ext/js_goal_news.txt')
        end
      end
    end
    it "list's element should link of 'www.jsgoal.jp/news/jsgoal/dddddddd.html'" do
      @js_goal_news.list.should be_all{ |e|
        e.uri.host =~ /^www\.jsgoal\.jp$/ && e.uri.path =~ /^\/news\/jsgoal\/\d{8}\.html$/
      }
    end
  end

  describe "JsGoalPhoto" do
    before do
      Entry.all.destroy!
      @js_goal_photo = JsGoalPhoto.new do
        File.new(File.dirname(__FILE__) + '/../ext/js_goal_photo.txt')
      end
    end
    it "list's element should link of 'www.jsgoal.jp/photo/dddddddd/dddddddd.html'" do
      @js_goal_photo.list.should be_all{ |e|
        e.uri.host =~ /^www\.jsgoal\.jp$/ && e.uri.path =~ /^\/photo\/\d{8}\/\d{8}\.html$/
      }
    end
  end
end
