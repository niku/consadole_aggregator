# -*- coding: utf-8 -*-
require 'rss'
require 'pstore'
require 'nokogiri'
require 'httpclient'

module ConsadoleAggregator
  module News
    class Register
      def initialize
        @sites = []
      end

      def name name
        builder = SiteBuilder.new name
        yield builder if block_given?
        @sites << builder.build
      end

      def register!
        News.const_set(:Sites, []) unless News.const_defined?(:Sites)
        News.const_get(:Sites).concat @sites
      end
    end

    class SiteBuilder
      def initialize name
        @name = name
      end

      def resource &block; @resource = block; end
      def parse_list &block; @parse_list = block; end
      def filter_article &block; @filter_article = block; end
      def parse_article &block; @parse_article = block; end

      def build
        site = Site.new @name
        site.resource = @resource if @resource
        site.list_parser = @parse_list if @parse_list
        site.article_filter = @filter_article if @filter_article
        site.article_parser = @parse_article if @parse_article
        site
      end
    end

    class Site
      class << self
        STORE_NAME = 'updated.pstore'
        def store
          @store ||= PStore.new(File.join(ConsadoleAggregator.root_dir, STORE_NAME))
        end
      end

      STORAGE_ELEMENT_SIZE = 200

      attr_writer :resource, :list_parser, :article_filter, :article_parser
      attr_reader :name

      def initialize name
        @name = name
      end

      def updated
        @updated ||= self.class.store.transaction { |s| s.fetch(name, []) }
      end

      def update
        resource = @resource.call
        list = @list_parser.call(resource).to_a
        list.select! &@article_filter if @article_filter
        list.map! &@article_parser if @article_parser
        list.reject! { |article| updated.include?(article) }
        list.each { |article|
          begin
            yield article if block_given?
            add_updated article
            ConsadoleAggregator.logger.info('%s: %s'%[name, article])
          rescue
            ConsadoleAggregator.logger.error('%s: %s'%[name, $!])
          end
        }
      rescue
        ConsadoleAggregator.logger.error('%s: %s'%[name, $!])
      end

      private
      def add_updated article
        @updated << article
        self.class.store.transaction { |s| s[name] = @updated.last(STORAGE_ELEMENT_SIZE) }
      end
    end

    def self.run &block
      Sites.each { |site| site.update &block }
    end

    def self.register!
      register = Register.new
      yield register if block_given?
      register.register!
    end

    register! do |sites|
      sites.name(:nikkansports) do |site|
        site.resource { HTTPClient.new.get_content('http://www.nikkansports.com/rss/soccer/jleague/consadole.rdf').force_encoding('UTF-8') }
        site.parse_list { |list| RSS::Parser.parse(list, false).items.reverse }
        site.parse_article { |article| { url: article.link, title: article.title } }
      end

      sites.name(:hochiyomiuri) do |site|
        site.resource { HTTPClient.new.get_content('http://hochi.yomiuri.co.jp/soccer/jleague/index.htm').force_encoding('UTF-8') }
        site.parse_list { |list| Nokogiri::HTML(list).search('div.list1 > ul > li a').reverse }
        site.filter_article { |article| article.text =~ /^【札幌】/ }
        site.parse_article { |article| { url:"http://hochi.yomiuri.co.jp#{article['href']}", title:article.text } }
      end

      sites.name(:asahi) do |site|
        site.resource { HTTPClient.new.get_content('http://www.asahi.com/sports/list/soccer/national_news.html').force_encoding('EUC-JP').encode('UTF-8') }
        site.parse_list { |list| Nokogiri::HTML(list).search('#HeadLine2 dl dt a').reverse }
        site.filter_article { |article| article.text =~ /札幌|コンサ/ }
        site.parse_article { |article| { url: "http://www.asahi.com#{article['href']}", title: article.text } }
      end

      sites.name(:mainichi) do |site|
        site.resource { HTTPClient.new.get_content('http://mainichi.jp/area/hokkaido/archive/').force_encoding('UTF-8') }
        site.parse_list { |list| Nokogiri::HTML(list).search('#Archive dl dd a').reverse }
        site.filter_article { |article| article.text =~ /コンサドーレ/ }
        site.parse_article { |article| { url: article['href'], title: article.text.strip } }
      end

      sites.name(:forzaconsadole) do |site|
        site.resource { HTTPClient.new.get_content('http://www.hokkaido-np.co.jp/news/e_index/?g=consadole').encode('UTF-8') }
        site.parse_list { |list| Nokogiri::HTML(list).search('ul.iSwBox > li > a').reverse }
        site.parse_article { |article| { url: article['href'], title: article.text } }
      end

      sites.name(:consaburn) do |site|
        site.resource { HTTPClient.new.get_content('http://www.hokkaido-np.co.jp/cont/consa-burn/index.html').encode('UTF-8') }
        site.parse_list { |list| Nokogiri::HTML(list).search('ul#news_list > li > a').reverse }
        site.parse_article { |article| { url: article['href'], title: article.text } }
      end

      sites.name(:consaclub) do |site|
        site.resource { HTTPClient.new.get_content('http://www.hokkaido-np.co.jp/cont/consa-club/index.html').encode('UTF-8') }
        site.parse_list { |list| Nokogiri::HTML(list).search('ul#news_list > li > a').reverse }
        site.parse_article { |article| { url: article['href'], title: article.text } }
      end

      sites.name(:consadolenews) do |site|
        site.resource { HTTPClient.new.get_content('http://www.consadole-sapporo.jp/news/atom.xml').force_encoding('UTF-8') }
        site.parse_list { |list| Nokogiri::XML(list).search('entry').reverse }
        site.parse_article { |article| { title: article.at('title').text, url: article.at('link')['href'] } }
      end

      sites.name(:consadolephotos) do |site|
        site.resource { HTTPClient.new.get_content('http://www.consadole-sapporo.jp/').force_encoding('UTF-8') }
        site.parse_list { |list| Nokogiri::HTML(list).search('div.anythingSlider img').reverse }
        site.parse_article { |article| { url: article['src'], title: article['alt'] } }
      end

      sites.name(:jsgoalnews) do |site|
        site.resource { HTTPClient.new.get_content('http://feeds.feedburner.com/jsgoal/jsgoal?format=xml').encode('UTF-8') }
        site.parse_list { |list| RSS::Parser.parse(list, false).items.reverse }
        site.filter_article { |article| article.title =~ /札幌/ }
        site.parse_article { |article|
          c = HTTPClient.new.get(article.link)
          c = HTTPClient.new.get(c.header['location'].first) while c.status == 301
          { url: c.header['location'].first, title: article.title }
        }
      end

      sites.name(:jsgoalphotos) do |site|
        site.resource { HTTPClient.new.get_content('http://feeds.feedburner.com/jsgoal/photo?format=xml').encode('UTF-8') }
        site.parse_list { |list| RSS::Parser.parse(list, false).items.reverse }
        site.filter_article { |article| article.title =~ /札幌/ }
        site.parse_article { |article|
          c = HTTPClient.new.get(article.link)
          c = HTTPClient.new.get(c.header['location'].first) while c.status == 301
          { url: c.header['location'].first, title: article.title }
        }
      end

      sites.name(:clubconsadole) do |site|
        site.resource { HTTPClient.new.get_content('http://club-consadole.jp/news/index.php?page=1').encode('UTF-8') }
        site.parse_list { |list| Nokogiri::HTML(list).search('li.news a').reverse }
        site.parse_article { |article| { url: article['href'], title: article.text.strip } }
      end

      sites.name(:gekisaka) do |site|
        site.resource { HTTPClient.new.get_content('http://web.geki.jp/category/news/domestic').encode('UTF-8') }
        site.parse_list { |list| Nokogiri::HTML(list).search('div.post-title a').reverse }
        site.filter_article { |article| article.text =~ /札幌/ }
        site.parse_article { |article| { url: "http://web.geki.jp#{article['href']}", title: article.text.strip }}
      end

      sites.name(:consadole_sapporo_tv) do |site|
        site.resource { HTTPClient.new.get_content('http://gdata.youtube.com/feeds/base/users/consadolesapporotv/uploads').encode('UTF-8') }
        site.parse_list { |list| RSS::Parser.parse(list, false).items }
        site.parse_article { |article| { url: article.link.href, title: article.title.content } }
      end
    end
  end
end
