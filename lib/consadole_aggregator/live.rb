# -*- coding: utf-8 -*-
require 'logger'
require 'uri'
require 'kconv'
require 'nokogiri'
require 'net/http'
require_relative 'live/timeline.rb'

module ConsadoleAggregator
  module Live
    BASE_URI = URI.parse('http://www.consadole-sapporo.jp/view/s674.html')

    def self.reserve reservation_time=nil, opt ={}
      Live.new(reservation_time, opt)
    end

    def self.get_resource
      Net::HTTP.get(BASE_URI).force_encoding('Shift_JIS')
    end

    def self.parse
      doc = Nokogiri::HTML.parse(get_resource.toutf8, nil, 'UTF-8')
      doc.search('hr + p').last.inner_html.split(/<br>|\n/).reverse.each_with_object([]) do |line, memo|
        timeline = Timeline.parse line
        memo << timeline if timeline
      end
    end

    class Live
      attr_reader :reservation_time, :posted, :times, :wait_sec

      def initialize reservation_time=nil, opt ={}
        @reservation_time = reservation_time
        @posted = []
        @wait_sec = opt[:wait_sec] || 30
        @times = opt[:times] || (60/@wait_sec)*120 # サッカーは120分あれば終わる
        @logger = opt[:logger] || Logger.new(File.expand_path('log/live.log'))
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

      private
      def be_daemonize
        Process.daemon
      end
    end
  end
end
