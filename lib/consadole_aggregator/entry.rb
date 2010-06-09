# -*- coding: utf-8 -*-
require 'nkf'
require 'uri'
require 'rss'
require 'net/http'
require 'nokogiri'
require 'dm-core'
require 'dm-types'
require 'dm-migrations'

DataMapper.setup(:default, 'sqlite3:db/db.sqlite3')
module ConsadoleAggregator
  module Entry
    class Entry
      include DataMapper::Resource
      property :id, Serial
      property :uri, URI
      property :title, String
    end
    DataMapper.auto_upgrade!

    module List
      attr_reader :list
      def old_items
        Entry.all.map{ |e| e.uri.to_s }
      end
      def new_items
        @list.reject{ |e| old_items.include? e.uri.to_s }
      end
      def build_document resource # for test
        case resource
        when URI
          Net::HTTP.get resource
        when File
          resource.read
        end
      end
    end

    class NikkanSports
      include List
      LIST_BASE_URI = URI.parse('http://www.nikkansports.com/rss/soccer/jleague/consadole.rdf')
      def initialize resource = LIST_BASE_URI
        doc = build_document resource
        @list = RSS::Parser.parse(doc, false).items.map{ |e|
          Entry.new(uri:URI.parse(e.link), title:e.title)
        }.reverse
      end
    end

    class HochiYomiuri
      include List
      LIST_BASE_URI = URI.parse('http://hochi.yomiuri.co.jp/hokkaido/soccer/index.htm')
      def initialize resource = LIST_BASE_URI
        doc = build_document resource
        @list = Nokogiri::HTML(doc, nil, 'UTF-8').search('div.list1 > ul > li a').inject([]){ |result,e|
          result << Entry.new(uri:LIST_BASE_URI + e['href'], title:e.text) if e.text =~ /…札幌$/
          result
        }.reverse
      end
    end

    class Asahi
      include List
      LIST_BASE_URI = URI.parse('http://mytown.asahi.com/hokkaido/newslist.php?d_id=0100019')
      def initialize resource = LIST_BASE_URI
        doc = build_document resource
        @list = Nokogiri::HTML(doc, nil, 'EUC-JP').search('ul.list > li a').map{ |e|
          Entry.new(uri:LIST_BASE_URI + e['href'], title:e.text)
        }.reverse
      end
    end

    module HookaidoNp
      include List
      def initialize
        doc = build_document getResource
        @list = Nokogiri::HTML(doc, nil, 'Shift_JIS').search(selector).map{ |e|
          Entry.new(uri:URI.parse(e['href']), title:e.text)
        }.reverse
      end
    end

    class ForzaConsadole
      include HookaidoNp
      def getResource
        URI.parse('http://www.hokkaido-np.co.jp/news/e_index/?g=consadole')
      end
      def selector
        'ul.iSwBox > li > a'
      end
    end

    class ConsaBurn
      include HookaidoNp
      def getResource
        URI.parse('http://www.hokkaido-np.co.jp/cont/consa-burn/index.html')
      end
      def selector
        'ul#news_list > li > a'
      end
    end

    class ConsaClub
      include HookaidoNp
      def getResource
        URI.parse('http://www.hokkaido-np.co.jp/cont/consa-club/index.html')
      end
      def selector
        'ul#news_list > li > a'
      end
    end

    class ConsadoleNews
      include List
      LIST_BASE_URI = URI.parse('http://www.consadole-sapporo.jp/news/diary.cgi')
      def initialize resource = LIST_BASE_URI
        doc = build_document resource
        @list = Nokogiri::HTML(doc, nil, 'UTF-8').search('table.frametable > tr  a').map{ |e|
          Entry.new(uri:URI.parse(e['href']), title:e.text)
        }.reverse
      end
    end

    class ConsadoleSponsorNews
      include List
      LIST_BASE_URI = URI.parse('http://www.consadole-sapporo.jp/snews/diary.cgi')
      def initialize resource = LIST_BASE_URI
        doc = build_document resource
        @list = Nokogiri::HTML(doc, nil, 'UTF-8').search('table.frametable > tr  a').map{ |e|
          Entry.new(uri:URI.parse(e['href']), title:e.text)
        }.reverse
      end
    end

    class ConsadolePhotos
      include List
      LIST_BASE_URI = URI.parse('http://www.consadole-sapporo.jp/comment.txt')
      PHOTO_BASE_URI = URI.parse('http://www.consadole-sapporo.jp/img/')
      def initialize resource = LIST_BASE_URI
        base = build_document resource
        doc = NKF.nkf('-SwX', base)
        @list = doc.split("\n").map{ |line|
          element = line.match(/^&?text(?<number>\d\d)=(?<title>.+)/)
          Entry.new(uri:PHOTO_BASE_URI + "#{element[:number]}.jpg", title:element[:title])
        }
      end
      def old_items
        Entry.all.map{ |e| e.title }
      end
      def new_items
        @list.reject{ |e| old_items.include? e.title }
      end
    end

    module JsGoal
      include List
      def initialize
        doc = build_document getResource
        @list = RSS::Parser.parse(doc, false).items.inject([]){ |result,e|
          result << Entry.new(uri:URI.parse(trace(e.link)), title:e.title) if e.title.include?('札幌')
          result
        }.reverse
      end
      def trace(uri_str, limit=10)
        raise ArgumentError, 'http redirect too deep' if limit == 0

        case response = Net::HTTP.get_response(URI.parse(uri_str))
        when Net::HTTPSuccess     then uri_str
        when Net::HTTPRedirection then trace(response['Location'], limit - 1)
        else
          response.error!
        end
      end
    end

    class JsGoalNews
      include JsGoal
      def getResource
        URI.parse('http://feeds.feedburner.com/jsgoal/jsgoal?format=xml')
      end
    end

    class JsGoalPhoto
      include JsGoal
      def getResource
        URI.parse('http://feeds.feedburner.com/jsgoal/photo?format=xml')
      end
    end
  end
end
