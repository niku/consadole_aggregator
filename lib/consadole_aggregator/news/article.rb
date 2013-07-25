require 'uri'

module ConsadoleAggregator::News
  class Article
    attr_reader :url, :title

    def initialize(url: '', title: '')
      @url = URI(url)
      @title = title
    end

    def == other
      other.respond_to?(:url) \
      && self.url == other.url \
      && other.respond_to?(:title) \
      && self.title == other.title
    end
  end
end
