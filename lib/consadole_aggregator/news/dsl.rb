module ConsadoleAggregator::News
  class DSL
    class << self
      def sites
        sites = Sites.new
        yield sites if block_given?
        sites.get
      end
    end

    class Sites
      def initialize
        @sites = []
      end

      def name source_name
        site = Site.new(Source.new(source_name))
        yield site if block_given?
        @sites << site.get
      end

      def get
        @sites
      end
    end

    class Site
      def initialize source
        @source = source
      end

      def resource &block
        @source.how_to_create_resource = block
      end

      def list &block
        @source.how_to_create_list = block
      end

      def elements &block
        @source.how_to_create_elements = block
      end

      def get
        @source
      end
    end
  end
end
