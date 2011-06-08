# -*- coding: utf-8 -*-
require 'logger'
require 'uri'
require 'kconv'
require 'nokogiri'
require 'net/http'
require_relative 'live/timeline.rb'

module ConsadoleAggregator
  module Live

    def self.reserve reservation_time=nil, opt ={}
      Live.new(reservation_time, opt)
    end

    class Live
      include Aggregatable
      attr_reader :reservation_time, :posted, :times, :wait_sec

      def initialize reservation_time=nil, opt ={}
        @reservation_time = reservation_time
        @posted = []
        @wait_sec = opt[:wait_sec] || 30
        @times = opt[:times] || (60/@wait_sec)*120 # サッカーは120分あれば終わる
        @logger = opt[:logger] || Logger.new(File.expand_path(File.dirname(__FILE__) + '/../../log/live.log'))
      end

      def execute &block
        be_daemonize
        wait_initial
        @logger.info 'start of loop'
        @times.times do |i|
          @logger.debug "#{i} times"
          update &block rescue @logger.error $!
          wait_interval
        end
        @logger.info 'end of loop'
      end

      def wait_initial
        return unless @reservation_time
        diff_sec = @reservation_time - Time.now
        wait_sec = diff_sec > 0 ? diff_sec : 0
        @logger.info "initial wait #{wait_sec} seconds"
        sleep wait_sec
      end

      def wait_interval
        sleep @wait_sec
      end

      def update
        new_timeline = ConsadoleAggregator::Live.parse - @posted
        new_timeline.each do |timeline|
          @logger.debug timeline
          yield timeline if block_given?
          @posted << timeline
        end
      end

      def self.get_resource
        ->{ Net::HTTP.get(URI.parse('http://www.consadole-sapporo.jp/view/s674.html')).toutf8 }
      end

      def self.parse_list
        ->(list){
          live_block = Nokogiri::HTML::parse(list)
            .search("hr + p")
            .last
            .inner_html
          lines = live_block
            .split(/<br>|\n/)
            .delete_if{ |line| line.empty? || line =~ /&lt;前|後半&gt;/ }
          lines.map{ |line| line.sub(/　+$/, "") }.reverse
        }
      end

      def self.parse_article
        ->(article){ Timeline.parse article }
      end

      private
      def be_daemonize
        Process.daemon
      end
    end
  end
end
