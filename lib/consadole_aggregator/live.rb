# -*- coding: utf-8 -*-
require 'uri'
require 'net/http'
require 'kconv'
require 'nokogiri'
require 'eventmachine'

module ConsadoleAggregator
  class Live
    class Runner
      attr_writer :length_of_a_game, :interval, :daemonize

      def initialize starting_time
        @starting_time = starting_time
        @length_of_a_game = 120 * 60
        @interval = 60
        @daemonize = true
      end

      def run &block
        Process.daemon if @daemonize

        starting = @starting_time - Time.now
        ending = starting + @length_of_a_game
        live = Live.new

        EM.run do
          EM.add_timer(starting) do
            EM.next_tick do
              EM.add_periodic_timer(@interval) do
                live.update &block
              end
            end
          end

          EM.add_timer(ending) do
            EM.stop
          end
        end
      end
    end

    def self.run starting_time, opt = {}
      runner = Runner.new starting_time
      runner.length_of_a_game = opt[:length_of_a_game] if opt[:length_of_a_game]
      runner.interval = opt[:interval] if opt[:interval]
      runner.daemonize = opt[:daemonize] unless opt[:daemonize].nil?
      runner.run &opt[:writer]
    end

    attr_reader :posted

    def initialize
      @posted = []
    end

    def update
      self.class
        .fetch
        .reject(&@posted.method(:include?))
        .each_with_object(@posted) { |post, posted|
        begin
          yield({ title: post }) if block_given?
          posted << post
          ConsadoleAggregator.logger.info post
        rescue
          ConsadoleAggregator.logger.error $!
        end
      }
    end

    private
    def self.parse document
      Nokogiri
        .parse(document)
        .search('p:last-of-type')
        .children
        .grep(Nokogiri::XML::Text)
        .map(&:text)
        .map(&:toutf8)
        .map { |t| t.tr('　', ' ') }
        .map(&:strip)
        .reject(&/<前|後半>/.method(:match))
        .reverse
    end

    def self.fetch
      uri = URI.parse('http://www.consadole-sapporo.jp/view/s674.html')
      doc = Net::HTTP.get(uri).force_encoding('SJIS')
      parse(doc)
    rescue
      []
    end
  end
end
