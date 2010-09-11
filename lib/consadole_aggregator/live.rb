# -*- coding: utf-8 -*-
require 'uri'
require 'open-uri'
require 'kconv'
require 'nokogiri'

module ConsadoleAggregator
  module Live
    class TimeLine
      attr_reader :time, :post
      def self.parse line
        if /(&lt;前半&gt;)|(&lt;後半&gt;)/ =~ line
          TimeLine.new
        else
          TimeLine.new(line.split('　'))
        end
      end
      def initialize line = nil
        @time, @post = *line
      end
      def empty?
        @time.nil? || @post.nil? || @time.empty? || @post.empty?
      end
    end
    class Live
      BASE_URI = URI.parse('http://www.consadole-sapporo.jp/view/s674.html')
      def self.parse doc_path
        doc = Nokogiri::HTML.parse(open(doc_path, 'r:Shift_JIS'){ |io| io.read.toutf8 }, nil, 'UTF-8')
        doc.search('hr + p').last.inner_html.split(/<br>|\n/).reverse.inject([]) do |result, line|
          timeline = TimeLine.parse line
          unless timeline.empty?
            result << timeline
          end
          result
        end
      end
      def self.sleeptime start_time
        time = start_time - Time.now rescue 0
        0 > time ? 0 : time
      end
      def initialize
        @posted = []
      end
      def new_timeline parsed
        parsed - @posted
      end
      def add_timeline timeline
        @posted << timeline
      end
    end
  end
end
