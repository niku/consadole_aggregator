module ConsadoleAggregator::News
  class Source
    attr_reader :name
    attr_writer :how_to_create_resource, :how_to_create_list, :how_to_create_elements

    def initialize name
      @name = name
      @how_to_create_resource = -> { [] }
      @how_to_create_list     = ->(v) { v }
      @how_to_create_elements  = ->(v) { v }
    end

    def create_resource
      @how_to_create_resource.call
    end

    def create_list
      resource = create_resource
      @how_to_create_list.call(resource)
    end

    def create_elements
      list = create_list
      list.map {|element|
        begin
          @how_to_create_elements.call(element)
        rescue
          nil
        end
      }
    end

    def get
      elements = create_elements
      elements.compact
    rescue
      []
    end

    def == other
      other.kind_of?(self.class) \
      && self.name == other.name
    end
  end
end
