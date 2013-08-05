# -*- coding: utf-8 -*-
require 'rss'
require 'pstore'
require 'nokogiri'
require 'httpclient'
require_relative 'news/store'
require_relative 'news/source'
require_relative 'news/dsl'
require_relative 'news/article'
require_relative 'news/updater'

module ConsadoleAggregator
  module News
    def self.update &block
      updaters.each do |updater|
        updater.invoke(&block)
      end
    end

    def self.updaters
      Sources.map {|source| Updater.new(source) }
    end

    Sources = DSL.sites do |sites|
      sites.name(:nikkansports) do |site|
        site.resource { HTTPClient.get_content('http://www.nikkansports.com/rss/soccer/jleague/consadole.rdf').force_encoding('UTF-8') }
        site.list { |list| RSS::Parser.parse(list, false).items.reverse }
        site.elements { |element| { url: element.link, title: element.title } }
      end

      sites.name(:hochiyomiuri) do |site|
        site.resource { HTTPClient.get_content('http://hochi.yomiuri.co.jp/soccer/jleague/index.htm').force_encoding('UTF-8') }
        site.list { |list| Nokogiri::HTML(list).search('div.list1 > ul > li a').reverse }
        site.elements { |element|
          { url:"http://hochi.yomiuri.co.jp#{element['href']}", title:element.text } if element.text =~ /^【札幌】/
        }
      end

      sites.name(:koutascheck) do |site|
        site.resource { HTTPClient.get_content('http://hochi.yomiuri.co.jp/feature/soccer/20130524-461413/index.htm').force_encoding('UTF-8') }
        site.list { |list| Nokogiri::HTML(list).search('div.list1 > ul > li a').reverse }
        site.elements { |element| { url:"http://hochi.yomiuri.co.jp#{element['href']}", title:element.text } }
      end

      sites.name(:asahi) do |site|
        site.resource { HTTPClient.get_content('http://www.asahi.com/sports/list/soccer/national_news.html').force_encoding('EUC-JP').encode('UTF-8') }
        site.list { |list| Nokogiri::HTML(list).search('#HeadLine2 dl dt a').reverse }
        site.elements { |element|
          { url: "http://www.asahi.com#{element['href']}", title: element.text } if element.text =~ /札幌|コンサ/
        }
      end

      sites.name(:mainichi) do |site|
        site.resource { HTTPClient.get_content('http://mainichi.jp/area/hokkaido/archive/').force_encoding('UTF-8') }
        site.list { |list| Nokogiri::HTML(list).search('#Archive dl dd a').reverse }
        site.elements { |element|
          { url: element['href'], title: element.text.strip } if element.text =~ /コンサドーレ/
        }
      end

      sites.name(:forzaconsadole) do |site|
        site.resource { HTTPClient.get_content('http://www.hokkaido-np.co.jp/news/e_index/?g=consadole').encode('UTF-8') }
        site.list { |list| Nokogiri::HTML(list).search('ul.iSwBox > li > a').reverse }
        site.elements { |element| { url: element['href'], title: element.text } }
      end

      sites.name(:consaburn) do |site|
        site.resource { HTTPClient.get_content('http://www.hokkaido-np.co.jp/cont/consa-burn/index.html').encode('UTF-8') }
        site.list { |list| Nokogiri::HTML(list).search('ul#news_list > li > a').reverse }
        site.elements { |element| { url: element['href'], title: element.text } }
      end

      sites.name(:consaclub) do |site|
        site.resource { HTTPClient.get_content('http://www.hokkaido-np.co.jp/cont/consa-club/index.html').encode('UTF-8') }
        site.list { |list| Nokogiri::HTML(list).search('ul#news_list > li > a').reverse }
        site.elements { |element| { url: element['href'], title: element.text } }
      end

      sites.name(:consadolenews) do |site|
        site.resource { HTTPClient.get_content('http://www.consadole-sapporo.jp/news/atom.xml').force_encoding('UTF-8') }
        site.list { |list| Nokogiri::XML(list).search('entry').reverse }
        site.elements { |element| { title: element.at('title').text, url: element.at('link')['href'] } }
      end

      sites.name(:consadolephotos) do |site|
        site.resource { HTTPClient.get_content('http://www.consadole-sapporo.jp/').force_encoding('UTF-8') }
        site.list { |list| Nokogiri::HTML(list).search('div.anythingSlider img').reverse }
        site.elements { |element| { url: element['src'], title: element['alt'] } }
      end

      sites.name(:consadoletickets) do |site|
        site.resource { HTTPClient.get_content('http://www.consadole-sapporo.jp/').force_encoding('UTF-8') }
        site.list { |list| Nokogiri::XML(list).search('#next-homegame') }
        site.elements { |element|
          next_match = element.at('dd').text.tr("\n", ' ')
          target = element.at('li.target').text
          now = element.at('li.now').text
          {
            url: 'http://www.consadole-sapporo.jp/ticket/guide/',
            title: "次のホームゲーム:#{next_match}, 目標チケット販売数:#{target}, 現在チケット販売数:#{now}"
          }
        }
      end

      sites.name(:jsgoalnews) do |site|
        site.resource { HTTPClient.get_content('http://feeds.feedburner.com/jsgoal/jsgoal?format=xml').encode('UTF-8') }
        site.list { |list|
          begin
            RSS::Parser.parse(list, false).items.reverse # FIXME sometimes fail
          rescue
            ConsadoleAggregator.logger.error('%s: %s'%[site.name, $!])
            []
          end
        }
        site.elements { |element|
          if element.title =~ /札幌/
            # redirect twice
            c1 = HTTPClient.get(element.link)
            c2 = HTTPClient.get(c1.header['location'].first)
            { url: c2.header['location'].first, title: element.title }
          else
            nil
          end
        }
      end

      sites.name(:jsgoalphotos) do |site|
        site.resource { HTTPClient.get_content('http://feeds.feedburner.com/jsgoal/photo?format=xml').encode('UTF-8') }
        site.list { |list|
          begin
            RSS::Parser.parse(list, false).items.reverse # FIXME sometimes fail
          rescue
            ConsadoleAggregator.logger.error('%s: %s'%[site.name, $!])
            []
          end
        }
        site.elements { |element|
          if element.title =~ /札幌/
            # redirect twice
            c1 = HTTPClient.get(element.link)
            c2 = HTTPClient.get(c1.header['location'].first)
            { url: c2.header['location'].first, title: element.title }
          else
            nil
          end
        }
      end

      sites.name(:clubconsadole) do |site|
        site.resource { HTTPClient.get_content('http://club-consadole.jp/news/index.php?page=1').encode('UTF-8') }
        site.list { |list| Nokogiri::HTML(list).search('li.news a').reverse }
        site.elements { |element| { url: element['href'], title: element.text.strip } }
      end

      sites.name(:gekisaka) do |site|
        site.resource { HTTPClient.new.get_content('http://web.geki.jp/category/news/domestic').encode('UTF-8') }
        site.list { |list| Nokogiri::HTML(list).search('div.post-title a').reverse }
        site.elements { |element|
          { url: "http://web.geki.jp#{element['href']}", title: element.text.strip } if element.text =~ /札幌/
        }
      end

      sites.name(:consadole_sapporo_tv) do |site|
        site.resource { HTTPClient.new.get_content('http://gdata.youtube.com/feeds/base/users/consadolesapporotv/uploads').encode('UTF-8') }
        site.list { |list| RSS::Parser.parse(list, false).items }
        site.elements { |element| { url: element.link.href, title: element.title.content } }
      end
    end
  end
end
