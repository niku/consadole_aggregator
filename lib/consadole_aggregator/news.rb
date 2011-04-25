# -*- coding: utf-8 -*-
require 'logger'
require 'rss'
require 'uri'
require 'kconv'
require 'net/http'
require 'yaml'
require 'nokogiri'

module ConsadoleAggregator
  module Aggregatable
    def get_new_articles
      get_resource = self.class.get_resource
      parse_list = self.class.parse_list
      parse_article = self.class.parse_article
      raise NotImplementedError unless get_resource && parse_list && parse_article
      list_url = get_resource.call
      article_urls = parse_list.call(list_url)
      article_urls.each_with_object([]) do |article_url, memo|
        article = parse_article.call(article_url)
        memo.push(article) if article && !get_strage.include?(article)
      end
    end

    def update
      get_new_articles.each do |article|
        begin
          yield article if block_given?
          @strage << article
        rescue
          @logger.error $!
        end
      end
      save_strage
    end

    def get_strage
      @strage ||= YAML.load_file(build_strage_path) || [] # fix when YAML.load_file is nil
    rescue
      @strage = []
    end

    def save_strage
      YAML.dump(@strage, File.new(build_strage_path, 'w'))
    end

    def build_strage_path
      class_name = /([^:]+)$/.match(self.class.to_s)[1]
      File.expand_path "db/#{class_name}.yaml"
    end

    # define class method's
    def self.included(mod)
      mod.extend ClassMethods
    end

    module ClassMethods
      attr_accessor :get_resource, :parse_list, :parse_article
    end
  end

  module News
    def self.get_resource(url_path)
      Net::HTTP.get(URI.parse(url_path)).toutf8
    end

    def self.trace(url_path, limit=10)
      raise ArgumentError, 'http redirect too deep' if limit == 0

      case response = Net::HTTP.get_response(URI.parse(url_path))
      when Net::HTTPSuccess     then url_path
      when Net::HTTPRedirection then trace(response['Location'], limit - 1)
      else
        response.error!
      end
    end

    {
      Nikkansports:
      [
       ->{ get_resource('http://www.nikkansports.com/rss/soccer/jleague/consadole.rdf') },
       ->(list){ RSS::Parser.parse(list, false).items.map{ |e| { url:e.link, title:e.title } }.reverse },
       ->(article){ article }
      ],
      Hochiyomiuri:
      [
       ->{ get_resource('http://hochi.yomiuri.co.jp/hokkaido/soccer/index.htm') },
       ->(list){ Nokogiri::HTML(list).search('div.list1 > ul > li a').reverse },
       ->(article){ { url:"http://hochi.yomiuri.co.jp/hokkaido/soccer#{article['href']}", title:article.text } if article.text =~ /…札幌$/ }
      ],
      Asahi:
      [
       ->{ get_resource('http://mytown.asahi.com/hokkaido/newslist.php?d_id=0100019') },
       ->(list){ Nokogiri::HTML(list).search('ul.list > li a').reverse },
       ->(article){ { url:"http://mytown.asahi.com/hokkaido/#{article['href']}", title:article.text } }
      ],
      Forzaconsadole:
      [
       ->{ get_resource('http://www.hokkaido-np.co.jp/news/e_index/?g=consadole') },
       ->(list){ Nokogiri::HTML(list).search('ul.iSwBox > li > a').reverse },
       ->(article){ { url:article['href'], title:article.text } }
      ],
      Consaburn:
      [
       ->{ get_resource('http://www.hokkaido-np.co.jp/cont/consa-burn/index.html') },
       ->(list){ Nokogiri::HTML(list).search('ul#news_list > li > a').reverse },
       ->(article){ { url:article['href'], title:article.text } }
      ],
      Consaclub:
      [
       ->{ get_resource('http://www.hokkaido-np.co.jp/cont/consa-club/index.html') },
       ->(list){ Nokogiri::HTML(list).search('ul#news_list > li > a').reverse },
       ->(article){ { url:article['href'], title:article.text } }
      ],
      Consadolenews:
      [
       ->{ get_resource('http://www.consadole-sapporo.jp/news/diary.cgi') },
       ->(list){ Nokogiri::HTML(list).search('table.frametable > tr  a').reverse },
       ->(article){ { url:article['href'], title:article.text } }
      ],
      Consadolesponsornews:
      [
       ->{ get_resource('http://www.consadole-sapporo.jp/snews/diary.cgi') },
       ->(list){ Nokogiri::HTML(list).search('table.frametable > tr  a').reverse },
       ->(article){ { url:article['href'], title:article.text } }
      ],
      Consadolephotos:
      [
       ->{ get_resource('http://www.consadole-sapporo.jp/comment.txt') },
       ->(list){ list.split("\n").reverse },
       ->(article){
         photo = article.match(/^&?text(?<number>\d\d)=(?<title>.+)/)
         { url:"http://www.consadole-sapporo.jp/img/#{photo[:number]}.jpg", title:photo[:title] }
       }
      ],
      Jsgoalnews:
      [
       ->{ get_resource('http://feeds.feedburner.com/jsgoal/jsgoal?format=xml') },
       ->(list){
         RSS::Parser.parse(list, false).items.each_with_object([]){ |e, memo|
           memo << { url:trace(e.link), title:e.title } if e.title.include?('札幌')
         }.reverse },
       ->(article){ article }
      ],
      Jsgoalphotos:
      [
       ->{ get_resource('http://feeds.feedburner.com/jsgoal/photo?format=xml') },
       ->(list){
         RSS::Parser.parse(list, false).items.each_with_object([]){ |e, memo|
           memo << { url:trace(e.link), title:e.title } if e.title.include?('札幌')
         }.reverse },
       ->(article){ article }
      ],
    }.each do |k,v|
      klass = Class.new do
        include Aggregatable
        @get_resource, @parse_list, @parse_article = *v
        def initialize logger=nil
          @logger = logger || Logger.new(File.expand_path(File.dirname(__FILE__) + '/../../log/news.log'))
        end
      end
      const_set(k, klass)
    end
  end
end
