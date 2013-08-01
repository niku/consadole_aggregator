require 'pstore'

module ConsadoleAggregator::News
  class Store
    class << self
      def store_path
        File.join(ConsadoleAggregator.root_dir, 'pstore')
      end

      def load name
        @pstore ||= PStore.new(store_path, true)
        new(@pstore, name)
      end
    end

    include Enumerable

    def initialize store, name
      @store = store
      @name = name
    end

    def each
      stored_value = @store.transaction(true) {|s| s.fetch(@name, []) }
      if block_given?
        stored_value.each {|e| yield e }
      else
        stored_value.each
      end
    end

    def add_if_new_item value
      @store.transaction {|s|
        stored_value = s.fetch(@name, [])
        if not stored_value.member?(value)
          begin
            yield value if block_given?
          rescue
            s.abort
          end
          stored_value << value
        end
        s[@name] = stored_value
      }
    end
  end
end
