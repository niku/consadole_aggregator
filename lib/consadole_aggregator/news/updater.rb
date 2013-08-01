module ConsadoleAggregator::News
  class Updater
    attr_reader :source

    def initialize source
      @source = source
    end

    def name
      source.name
    end

    def articles
      source.get
    end

    def store
      @store ||= Store.load(name)
    end

    def invoke &to_do_if_new_member
      articles.each do |article|
        store.add_if_new_item(article, &to_do_if_new_member)
      end
    end

    def == other
      other.kind_of?(self.class) \
      && self.source == other.source
    end
  end
end
