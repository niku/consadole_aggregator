# -*- coding: utf-8 -*-
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
        @times = opt[:times] ? opt[:times] : 120 # サッカーは120分あれば終わる
        @wait_sec = opt[:wait_sec] ? opt[:wait_sec] : 1
      end

      def execute &block
        be_daemonize
        wait_initial
        @times.times do
          update &block rescue LOGGER.error $!
          sleep @wait_sec
        end
      end

      def wait_initial
        return unless @reservation_time
        wait_sec = @reservation_time - Time.now
        sleep wait_sec if wait_sec > 0
      end

      def update
        new_timeline = ConsadoleAggregator::Live.parse - @posted
        new_timeline.each do |timeline|
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
