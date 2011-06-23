require 'logger'
require 'yaml'

module ConsadoleAggregator
  module Aggregatable
    def initialize logger=nil
      @logger = logger || Logger.new(nil)
    end

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
      @logger.info('begin of update')
      get_new_articles.each do |article|
        begin
          yield article if block_given?
          @strage << article
        rescue
          @logger.error $!
        end
      end
      save_strage
      @logger.info('end of update')
    end

    def get_strage
      @strage ||= YAML.load_file(build_strage_path) || [] # fix when YAML.load_file is nil
    rescue
      @logger.error $!
      raise
    end

    def save_strage
      YAML.dump(@strage, File.new(build_strage_path, 'w'))
    end

    def build_strage_path
      class_name = /([^:]+)$/.match(self.class.to_s)[1]
      File.expand_path(File.dirname(__FILE__) + "/../../db/#{class_name}.yaml")
    end

    # define class method's
    def self.included(mod)
      mod.extend ClassMethods
    end

    module ClassMethods
      attr_accessor :get_resource, :parse_list, :parse_article
    end
  end
end
